Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 66CE56B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 08:55:36 -0400 (EDT)
Message-ID: <50474BBB.2070509@redhat.com>
Date: Wed, 05 Sep 2012 15:55:23 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V1 0/2] Enable clients to schedule in mmu_notifier methods
References: <1346748081-1652-1-git-send-email-haggaie@mellanox.com> <20120904150615.f6c1a618.akpm@linux-foundation.org>
In-Reply-To: <20120904150615.f6c1a618.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Haggai Eran <haggaie@mellanox.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

On 09/05/2012 01:06 AM, Andrew Morton wrote:
> On Tue,  4 Sep 2012 11:41:19 +0300
> Haggai Eran <haggaie@mellanox.com> wrote:
> 
>> > This patchset is a preliminary step towards on-demand paging design to be
>> > added to the Infiniband stack.
> 
> The above sentence is the most important part of the patchset.  Because
> it answers the question "ytf is Haggai sending this stuff at me".
> 
> I'm unsure if the patchset adds runtime overhead but it does add
> maintenance overhead (perhaps we can reduce this - see later emails). 
> So we need to take a close look at what we're getting in return for
> that overhead, please.
> 
> Exactly why do we want on-demand paging for Infiniband?  Why should
> anyone care?  What problems are users currently experiencing?  How many
> users and how serious are the problems and what if any workarounds are
> available?
> 
> Is there any prospect that any other subsystems will utilise these
> infrastructural changes?  If so, which and how, etc?
> 
> 
> 
> IOW, sell this code to us!

kvm may be a buyer.  kvm::mmu_lock, which serializes guest page faults,
also protects long operations such as destroying large ranges.  It would
be good to convert it into a spinlock, but as it is used inside mmu
notifiers, this cannot be done.

(there are alternatives, such as keeping the spinlock and using a
generation counter to do the teardown in O(1), which is what the "may"
is doing up there).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
