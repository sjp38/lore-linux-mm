Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFC86B0085
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 14:27:39 -0500 (EST)
Date: Tue, 16 Dec 2008 11:28:39 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
 restart
In-Reply-To: <4947FBC8.2000601@google.com>
Message-ID: <alpine.LFD.2.00.0812161116380.14014@localhost.localdomain>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu> <1228498282-11804-4-git-send-email-orenl@cs.columbia.edu> <4947FBC8.2000601@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 16 Dec 2008, Mike Waychison wrote:
> 
> set_fs(fs) here

Btw, this all is an excellent example of why people should try to aim for 
small functions and use lots of them.

It's often _way_ more readable to do

	static inline int __some_fn(...)
	{
		.. do the real work here ..
	}

	int some_fn(...)
	{
		int retval;

		prepare();
		retval = __some_fn(..)
		finish();

		return retval;
	}

where "prepare/finish" can be about locking, or set_fs(), or allocation 
and de-allocation of temporary buffers, or any number of things like that.

With set_fs() in particular, the wrapper function also tends to be the 
perfect place to change a regular (kernel) pointer into a user pointer. 
IOW, it's the place to make sparse happy, where you can do things like

	uptr = (__force void __user *)ptr;

and comment on the fact that the forced user pointer cast is valid only 
because of the set_fs().

Because it looks like the code isn't sparse-clean.

Btw, I also think that code like this is bogus:

	nwrite = file->f_op->write(file, addr, nleft, &file->f_pos);

because you're not supposed to pass in the raw file->f_pos to that 
function. It's fundamentally thread-unsafe. I realize that maybe you don't 
care, but the thing is, you're supposed to do

	loff_t pos = file->pos;
	..
	nwrite = file->f_op->write(file, addr, nleft, &pos);
	..
	file->f_pos = pos;

and in fact preferably use "file_pos_read()" and "file_pos_write()" (but 
we've never exposed them outside of fs/read_write.c, so I guess we should 
do that).

And yes, I realize that some code does take the address of f_pos directly 
(splice, nfsctl, others), and I realize that it works, but it's still bad 
form. Please don't add more of them.

			Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
