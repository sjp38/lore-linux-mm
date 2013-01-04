Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 0AC546B005D
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 19:50:21 -0500 (EST)
Received: by mail-vc0-f174.google.com with SMTP id d16so15763258vcd.19
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 16:50:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357260005.4930.6.camel@kernel.cn.ibm.com>
References: <1354344987-28203-1-git-send-email-walken@google.com>
	<20121203150110.39c204ff.akpm@linux-foundation.org>
	<CANN689FfWVV4MyTUPKZQgQAWW9Dfdw9f0fqx98kc+USKj9g7TA@mail.gmail.com>
	<20121203164322.b967d461.akpm@linux-foundation.org>
	<20121204144820.GA13916@google.com>
	<1355968594.1415.4.camel@kernel-VirtualBox>
	<CANN689FoSGMUi0mC6dzXe5tXo-BL_4eFZ1NF-De38x8mNhPXcg@mail.gmail.com>
	<1357260005.4930.6.camel@kernel.cn.ibm.com>
Date: Thu, 3 Jan 2013 16:50:20 -0800
Message-ID: <CANN689HQjbXEpWhv5KuaOt2NBEokiOguCXnsum2Bd994zkw6tA@mail.gmail.com>
Subject: Re: [PATCH] mm: protect against concurrent vma expansion
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Thu, Jan 3, 2013 at 4:40 PM, Simon Jeons <simon.jeons@gmail.com> wrote:
> On Wed, 2012-12-19 at 19:01 -0800, Michel Lespinasse wrote:
>> Hi Simon,
>>
>> On Wed, Dec 19, 2012 at 5:56 PM, Simon Jeons <simon.jeons@gmail.com> wrote:
>> > One question.
>> >
>> > I found that mainly callsite of expand_stack() is #PF, but it holds
>> > mmap_sem each time before call expand_stack(), how can hold a *shared*
>> > mmap_sem happen?
>>
>> the #PF handler calls down_read(&mm->mmap_sem) before calling expand_stack.
>>
>> I think I'm just confusing you with my terminology; shared lock ==
>> read lock == several readers might hold it at once (I'd say they share
>> it)
>
> Sorry for my late response.
>
> Since expand_stack() will modify vma, then why hold a read lock here?

Well, it'd be much nicer if we had a write lock, I think. But, we
didn't know when taking the lock that we'd end up having to expand
stacks.

What happens is that page faults don't generally modify vmas, so they
get a read lock (just to know what vma the fault is happening in) and
then fault in the page.

expand_stack() is the one exception to that - after getting the read
lock as usual, we notice that the fault is not in any vma right now,
but it's close enough to an expandable vma.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
