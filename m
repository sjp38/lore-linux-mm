From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	<20070606204432.b670a7b1.akpm@linux-foundation.org>
	<787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	<20070607162004.GA27802@vino.hallyn.com>
	<m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
	<787b0d920706072141s5a34ecb3n97007ad857ba4dc9@mail.gmail.com>
Date: Thu, 07 Jun 2007 23:55:53 -0600
In-Reply-To: <787b0d920706072141s5a34ecb3n97007ad857ba4dc9@mail.gmail.com>
	(Albert Cahalan's message of "Fri, 8 Jun 2007 00:41:45 -0400")
Message-ID: <m1ejknrnva.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <acahalan@gmail.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbadari@us.ibm.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

"Albert Cahalan" <acahalan@gmail.com> writes:

> On 6/7/07, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
>> So it looks to me like we need to do three things:
>> - Fix the inode number
>> - Fix the name on the hugetlbfs dentry to hold the key
>> - Add a big fat comment that user space programs depend on this
>>   behavior of both the dentry name and the inode number.
>
> Assuming that this proposed fix goes in:
>
> Since the inode number is the shmid, and this is a number
> that the kernel randomly chooses AFAIK, there should be
> no need to have different shm segments sharing the same
> inode number.

Where we run into inode number confusion is that all of
these shm segments are actually files on a tmpfs filesystem
somewhere, and by making the inode number the shmid we loose
the tmpfs inode number.  So it is possible we get tmpfs inode
number conflicts.  However the inode number is not used for
anything, and the files are not visible in any other way except
as shm segments so it doesn't matter.

There is another case with ipc namespaces where we ultimately need
to support duplicate shmids on the same machine (so migration
is a possibility).  However by and large the user space
processes with duplicate ids should be invisible to each other.

> The situation with the key is a bit more disturbing, though
> we already hit that anyway when IPC_PRIVATE is used.
> (why anybody would NOT use IPC_PRIVATE is a mystery)
> So having the key in the name doesn't make things worse.

Having "SYSV" in the name appears mandatory.  Otherwise you
don't even know it is a shm file. Although I may be confused.

> I have some concern about the device minor number.
> This should be the same for all shm mappings; I do not
> know if the behavior changed.

So I haven't changed anything here.  But I haven't really
looked either.

I don't have a clue if hugetlbfs files use the same device minor
number as tmpfs files.

Hmm.  Thinking about this I have just realized that we may want
to approach this a little differently.  Currently I am reusing
the dentry and inode structure that hugetlbfs and tmpfs return
me, and simply have a distinct struct file for each shm mapping.

There is a little more cost but it may actually make sense to have
a dentry and inode that is specific to shm.c so we can do whatever
we need to without adding requirements to the normal tmpfs or hugtlb
code.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
