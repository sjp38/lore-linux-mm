Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [11/14] vcompound: Fallbacks for order 1 stack allocations on IA64 and x86
Date: Tue, 25 Mar 2008 12:09:49 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843ECE9DDFA@orsmsx424.amr.corp.intel.com>
In-reply-to: <Pine.LNX.4.64.0803251036410.15870@schroedinger.engr.sgi.com>
References: <20080321061726.782068299@sgi.com> <20080321.002502.223136918.davem@davemloft.net> <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com> <20080321.145712.198736315.davem@davemloft.net> <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com> <1FE6DD409037234FAB833C420AA843ECE5B84D@orsmsx424.amr.corp.intel.com> <Pine.LNX.4.64.0803251036410.15870@schroedinger.engr.sgi.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I thought the only pinned TLB entry was for the per cpu area? How does it 
> pin the TLB? The expectation is that a single TLB covers the complete 
> stack area? Is that a feature of fault handling?

Pinning TLB entries on ia64 is done using TR registers with the "itr"
instruction.  Currently we have the following pinned mappings:

itr[0] : maps kernel code.  64MB page at virtual 0xA000000100000000
dtr[1] : maps kernel data.  64MB page at virtual 0xA000000100000000

itr[1] : maps PAL code as required by architecture

dtr[1] : maps an area of region 7 that spans kernel stack
         page size is kernel granule size (default 16M).
         This mapping needs to be reset on a context switch
         where we move to a stack in a different granule.

We used to used dtr[2] to map the 64K per-cpu area at 0xFFFFFFFFFFFF0000
but Ken Chen found that performance was better to use a dynamically
inserted DTC entry from the Alt-TLB miss handler which allows this
entry in the TLB to be available for generic use (on most processor
models).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
