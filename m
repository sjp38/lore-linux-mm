Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 071286B0083
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 17:40:42 -0500 (EST)
Received: by wibhi20 with SMTP id hi20so354226wib.14
        for <linux-mm@kvack.org>; Thu, 01 Mar 2012 14:40:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120301141007.274ad458.akpm@linux-foundation.org>
References: <1330593530-2022-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120301141007.274ad458.akpm@linux-foundation.org>
Date: Thu, 1 Mar 2012 17:40:41 -0500
Message-ID: <CA+5PVA4AcTWHsUskGqxdka2G7JMsDpjtdhw23vSHafgAGg4opQ@mail.gmail.com>
Subject: Re: [PATCH -V2] hugetlbfs: Drop taking inode i_mutex lock from hugetlbfs_read
From: Josh Boyer <jwboyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, viro@zeniv.linux.org.uk, hughd@google.com, linux-kernel@vger.kernel.org

On Thu, Mar 1, 2012 at 5:10 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Thu, =A01 Mar 2012 14:48:50 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> Taking i_mutex lock in hugetlbfs_read can result in deadlock with mmap
>> as explained below
>> =A0Thread A:
>> =A0 read() on hugetlbfs
>> =A0 =A0hugetlbfs_read() called
>> =A0 =A0 i_mutex grabbed
>> =A0 =A0 =A0hugetlbfs_read_actor() called
>> =A0 =A0 =A0 __copy_to_user() called
>> =A0 =A0 =A0 =A0page fault is triggered
>> =A0Thread B, sharing address space with A:
>> =A0 mmap() the same file
>> =A0 =A0->mmap_sem is grabbed on task_B->mm->mmap_sem
>> =A0 =A0 hugetlbfs_file_mmap() is called
>> =A0 =A0 =A0attempt to grab ->i_mutex and block waiting for A to give it =
up
>> =A0Thread A:
>> =A0 pagefault handled blocked on attempt to grab task_A->mm->mmap_sem,
>> =A0which happens to be the same thing as task_B->mm->mmap_sem. =A0Block =
waiting
>> =A0for B to give it up.
>>
>> AFAIU i_mutex lock got added to =A0hugetlbfs_read as per
>> http://lkml.indiana.edu/hypermail/linux/kernel/0707.2/3066.html
>> to take care of the race between truncate and read. This patch fix
>> this by looking at page->mapping under page_lock (find_lock_page())
>> to ensure; the inode didn't get truncated in the range during a
>> parallel read.
>>
>> Ideally we can extend the patch to make sure we don't increase i_size
>> in mmap. But that will break userspace, because application will now
>> have to use truncate(2) to increase i_size in hugetlbfs.
>
> Looks OK to me.
>
> Given that the bug has been there for four years, I'm assuming that
> we'll be OK merging this fix into 3.4. =A0Or we could merge it into 3.4
> and tag it for backporting into earlier kernels - it depends on whether
> people are hurting from it, which I don't know?

We've gotten a few lockdep reports about it in Fedora on various kernels.
A CC to stable might be nice.

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
