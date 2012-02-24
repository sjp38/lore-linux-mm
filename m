Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 744C66B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 13:58:40 -0500 (EST)
Received: by qadz32 with SMTP id z32so493302qad.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 10:58:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F47B781.2050300@gmail.com>
References: <4F32B776.6070007@gmail.com>
	<1328972596-4142-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<CAHGf_=oi8_s0Bxn4qSD7S_FBSgp29BPXor4hCf5-kekGnf3qEw@mail.gmail.com>
	<CAAHN_R2Awa5X3B09541grAPLkm9RzL9DnixUKFJXpz=1ZkPTFg@mail.gmail.com>
	<4F47B781.2050300@gmail.com>
Date: Sat, 25 Feb 2012 00:28:38 +0530
Message-ID: <CAAHN_R3-Rh1_vQAH5DHxw56Ukhif0Oq91qghrYoQ04nx=adUyQ@mail.gmail.com>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, vapier@gentoo.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Feb 24, 2012 at 9:44 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> Oh, maybe generically you are right. but you missed one thing. Before
> your patch, stack or not stack are address space property. thus, using
> /proc/pid/maps makes sense. but after your patch, it's no longer memory
> property. applications can use heap or mapped file as a stack. then, at
> least, current your code is wrong. the code assume each memory property
> are exclusive.

Right, but I cannot think of any other alternative that does not
involve touching some sensitive code.

The setcontext family of functions where any heap, stack or even data
area portion could be used as stack, break the very concept of an
entire vma being used as a stack. In such a scenario the kernel can
only show what it knows, which is that a specific vma is being used as
a stack. I agree that it is not correct to show the entire vma as
stack, but there doesn't seem to be a better way right now in that
implementation. FWIW, if the stack space is allocated in heap, it will
show up as heap and not stack since the former gets preference.

> Moreover, if pthread stack is unimportant, I wonder why we need this patch
> at all. Which application does need it? and When?

Right, my original intent was to mark stack vmas allocated by
pthreads, which included those vmas that are in the pthreads cache.
However, this means that the kernel does not have any real control
over what it marks as stack. Also, the concept is very specific to the
glibc pthreads implementation and we're essentially just making the
kernel spit out some data blindly for glibc.

The other solution I can think of is to have stack_start as a task
level property so that each task knows their stack vma start (obtained
from its sys_clone call and not from mmap). This however means
increasing the size of task_struct by sizeof(unsigned long). Is that
overhead acceptable?

-- 
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
