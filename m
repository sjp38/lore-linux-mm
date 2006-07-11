Date: Tue, 11 Jul 2006 10:35:58 -0500 (CDT)
From: Chase Venters <chase.venters@clientec.com>
Subject: RE: Commenting out out_of_memory() function in __alloc_pages()
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMEEJMDCAA.abum@aftek.com>
Message-ID: <Pine.LNX.4.64.0607111025320.19812@turbotaz.ourhouse>
References: <BKEKJNIHLJDCFGDBOHGMEEJMDCAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Robin Holt <holt@sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, nickpiggin@yahoo.com.au, Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2006, Abu M. Muttalib wrote:

>
> I fail to understand that why the OS doesn't return NULL as per man pages of
> malloc. It insteat results in OOM.

Well, my "malloc" manpage describes the Linux behavior under "Bugs", 
though it gives the overcommit practice a harsh and unfair treatment. Let 
me give you an example of why the OS behaves in this way.

Say I've got an Apache web server that is going to fork() 10 children. 
Under traditional fork() semantics, you need 10 copies of all of the 
memory holding stuff like configuration structures, etc. There are two 
reasons why we might not want 10 copies:

1. Some of those pages of data won't change. So why have 10 copies that 
you're going to have to constantly move in and out of cache?

2. Why waste that memory in the first place?

Now, if we were just worried about #1, we could "reserve" room for 9 
copies and still share the single copy (in a CoW scheme). But the act of 
reserving the room would probably just slow fork() down needlessly (when 
fork() is one of the most common and possibly expensive system calls).

Now apps get overcommitted memory too because they do things like ask for 
a ton of memory and then not use it, or use it gradually... in either 
case, Linux (by default) gambles that it can make better choices.

And it turns out that in 999 out of 1000 cases, it can.

If you want strict malloc(), you can use the sysctl to turn off 
overcommit. It's even appropriate to do so for certain applications.

> ~Abu.
>

Thanks,
Chase

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
