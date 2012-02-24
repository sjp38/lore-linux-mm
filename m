Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id EDC056B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 11:14:57 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so3374733pbc.14
        for <linux-mm@kvack.org>; Fri, 24 Feb 2012 08:14:57 -0800 (PST)
Message-ID: <4F47B781.2050300@gmail.com>
Date: Fri, 24 Feb 2012 11:14:57 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
References: <4F32B776.6070007@gmail.com> <1328972596-4142-1-git-send-email-siddhesh.poyarekar@gmail.com> <CAHGf_=oi8_s0Bxn4qSD7S_FBSgp29BPXor4hCf5-kekGnf3qEw@mail.gmail.com> <CAAHN_R2Awa5X3B09541grAPLkm9RzL9DnixUKFJXpz=1ZkPTFg@mail.gmail.com>
In-Reply-To: <CAAHN_R2Awa5X3B09541grAPLkm9RzL9DnixUKFJXpz=1ZkPTFg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, vapier@gentoo.org, Andrew Morton <akpm@linux-foundation.org>

>> Sigh. No, I missed one thing. If application use
>> makecontext()/swapcontext() pair,
>> ESP is not reliable way to detect pthread stack. At that time the
>> stack is still marked
>> as anonymous memory.
>
> This is not wrong, because it essentially gives the correct picture of
> the state of that task -- the task is using another vma as a stack
> during that point and not the one it was allotted by pthreads during
> thread creation.
>
> I don't think we can successfully stick to the idea of trying to mark
> stack space allocated by pthreads but not used by any task *currently*
> as stack as long as the allocation happens outside the kernel space.
> The only way to mark this is either by marking the stack as
> VM_GROWSDOWN (which will make the stack grow and break some pthreads
> functions) or create a new flag, which a simple display such as this
> does not deserve. So it's best that this sticks to what the kernel
> *knows* is being used as stack.

Oh, maybe generically you are right. but you missed one thing. Before
your patch, stack or not stack are address space property. thus, using
/proc/pid/maps makes sense. but after your patch, it's no longer memory
property. applications can use heap or mapped file as a stack. then, at
least, current your code is wrong. the code assume each memory property
are exclusive.

Moreover, if pthread stack is unimportant, I wonder why we need this patch
at all. Which application does need it? and When?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
