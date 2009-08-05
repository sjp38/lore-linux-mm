Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8EF176B0083
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:20:20 -0400 (EDT)
Message-ID: <4A79A468.2020200@redhat.com>
Date: Wed, 05 Aug 2009 18:25:28 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <4A793B92.9040204@redhat.com> <4A7993F4.9020008@redhat.com> <4A79A16A.1050401@redhat.com> <4A79A1FB.6010406@redhat.com>
In-Reply-To: <4A79A1FB.6010406@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/05/2009 06:15 PM, Rik van Riel wrote:
> Avi Kivity wrote:
>
>>> If so, we could unmap them when they get moved from the
>>> active to the inactive list, and soft fault them back in
>>> on access, emulating the referenced bit for EPT pages and
>>> making page replacement on them work like it should.
>>
>> It should be easy to implement via the mmu notifier callback: when 
>> the mm calls clear_flush_young(), mark it as young, and unmap it from 
>> the EPT pagetable.
>
> You mean "mark it as old"?

I meant 'return young, and drop it from the EPT pagetable'.

If we use the present bit as a replacement for the accessed bit, present 
means young, and clear_flush_young means "if present, return young and 
unmap, otherwise return old'.

See kvm_age_rmapp() in arch/x86/kvm/mmu.c.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
