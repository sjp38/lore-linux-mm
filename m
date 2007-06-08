From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	<20070606204432.b670a7b1.akpm@linux-foundation.org>
	<787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	<20070607162004.GA27802@vino.hallyn.com>
Date: Thu, 07 Jun 2007 21:45:37 -0600
In-Reply-To: <20070607162004.GA27802@vino.hallyn.com> (Serge E. Hallyn's
	message of "Thu, 7 Jun 2007 11:20:04 -0500")
Message-ID: <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Albert Cahalan <acahalan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbadari@us.ibm.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

"Serge E. Hallyn" <serge@hallyn.com> writes:

> Ok, so IIUC the problem was that inode->i_ino was being set to the id,
> and the id can be the same for different things in two namespaces.

There is nothing preventing inode number collisions in this code even
without multiple namespaces, and even when it was functioning
correctly.  However as it does not seem possible to find these files
through normal filesystem operations that does not seem to be a problem.

> So aside from not using the id as inode->i_ino, an alternative is to use
> a separate superblock, spearate mqeueue fs, for each ipc ns.
>
> I haven't looked at that enough to see whether it's feasible, i.e. I 
> don't know what else mqueue fs is used for.  Eric, does that sound
> reasonable to you?

At this point given that we actually have a small user space dependency
and the fact that after I have reviewed the code it looks harmless to
change the inode number of those inodes, in both cases they are just
anonymous inodes generated with new_inode, and anything that we wrap
is likely to be equally so.

So it looks to me like we need to do three things:
- Fix the inode number
- Fix the name on the hugetlbfs dentry to hold the key
- Add a big fat comment that user space programs depend on this
  behavior of both the dentry name and the inode number.

So Badari it looks like your original patch plus a little bit is
what we need.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
