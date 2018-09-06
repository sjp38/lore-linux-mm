Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44E296B7916
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 10:35:39 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c5-v6so5633259plo.2
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 07:35:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id y141-v6si5596396pfb.331.2018.09.06.07.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 07:35:37 -0700 (PDT)
Subject: Re: [RFC][PATCH 4/5] [PATCH 4/5] kvm-ept-idle: EPT page table walk
 for A bits
References: <20180901112818.126790961@intel.com>
 <20180901124811.644382292@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e92183a0-b1ca-c45e-5b3f-e69f5886a368@intel.com>
Date: Thu, 6 Sep 2018 07:35:37 -0700
MIME-Version: 1.0
In-Reply-To: <20180901124811.644382292@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 09/01/2018 04:28 AM, Fengguang Wu wrote:
> (2) would need fundemental changes to the interface. It seems existing solutions
> for sparse files like SEEK_HOLE/SEEK_DATA and FIEMAP ioctl may not serve this
> situation well. The most efficient way could be to fill user space read()
> buffer with an array of small extents:

I've only been doing kernel development a few short years, but I've
learned that designing user/kernel interfaces is hard.

A comment in an RFC saying that we need "fundamental changes to the
interface" seems to be more of a cry for help than a request for
comment.  This basically says to me: ignore the interface, it's broken.

> This borrows host page table walk macros/functions to do EPT walk.
> So it depends on them using the same level.

Have you actually run this code?

How does this work?  It's walking the 'ept_root' that appears to be a
guest CR3 register value.  It doesn't appear to be the host CR3 value of
the qemu (or other hypervisor).

I'm also woefully confused why you are calling these EPT walks and then
walking the x86-style page tables.  EPT tables don't have the same
format as x86 page tables, plus they don't start at a CR3-provided value.

I'm also rather unsure that when running a VM, *any* host-format page
tables get updated A/D bits.  You need a host vaddr to do a host-format
page table walk in the host page tables, and the EPT tables do direct
guest physical to host physical translation.  There's no host vaddr
involved at all in those translations.

> +		if (!ept_pte_present(*pte) ||
> +		    !ept_pte_accessed(*pte))
> +			idle = 1;

Huh?  So, !Present and idle are treated the same?  If you had large
swaths of !Present memory, you would see that in this interface and say,
"gee, I've got a lot of idle memory to migrate" and then go do a bunch
of calls to migrate it?  That seems terminally wasteful.

Who is going to use this?

Do you have an example, at least dummy app?

Can more than one app read this data at the same time?  Who manages it?
Who owns it?  Are multiple reads destructive?

This entire set is almost entirely comment-free except for the
occasional C++ comments.  That doesn't inspire confidence.
