Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7238C6B030D
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:54:32 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 199so410525pgc.11
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:54:32 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u6si428688pld.270.2018.01.03.00.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 00:54:31 -0800 (PST)
Message-ID: <5A4C9ACF.2090000@intel.com>
Date: Wed, 03 Jan 2018 16:56:47 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com> <20171221210327.GB25009@bombadil.infradead.org> <5A3CC707.9070708@intel.com> <20180102140906.GC8222@bombadil.infradead.org>
In-Reply-To: <20180102140906.GC8222@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, penguin-kernel@I-love.SAKURA.ne.jp

On 01/02/2018 10:09 PM, Matthew Wilcox wrote:
> On Fri, Dec 22, 2017 at 04:49:11PM +0800, Wei Wang wrote:
>> Thanks for the improvement. I also found a small bug in xb_zero. With the
>> following changes, it has passed the current test cases and tested with the
>> virtio-balloon usage without any issue.
> Thanks; I applied the change.  Can you supply a test-case for testing
> xb_zero please?
>

Sure. Please check below the test cases. Do you plan to send out the new 
version of xbitmap yourself? If so, I will wait for that to send out the 
virtio-balloon patches.


static void xbitmap_check_zero_bits(void)
{
         assert(xb_empty(&xb1));

         /* Zero an empty xbitmap should work though no real work to do */
         xb_zero(&xb1, 0, ULONG_MAX);
         assert(xb_empty(&xb1));

         xb_preload(GFP_KERNEL);
         assert(xb_set_bit(&xb1, 0) == 0);
         xb_preload_end();

         /* Overflow test */
         xb_zero(&xb1, ULONG_MAX - 10, ULONG_MAX);
         assert(xb_test_bit(&xb1, 0));

         xb_preload(GFP_KERNEL);
         assert(xb_set_bit(&xb1, ULONG_MAX) == 0);
         xb_preload_end();

         xb_zero(&xb1, 0, ULONG_MAX);
         assert(xb_empty(&xb1));
}


/*
  * In the following tests, preload is called once when all the bits to set
  * locate in the same ida bitmap. Otherwise, it is recommended to call
  * preload for each xb_set_bit.
  */
static void xbitmap_check_bit_range(void)
{
         unsigned long nbit = 0;

         /* Regular test1: node = NULL */
         xb_preload(GFP_KERNEL);
         xb_set_bit(&xb1, 700);
         xb_preload_end();
         assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
         assert(nbit == 700);
         nbit++;
         assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
         assert(nbit == 701);
         xb_zero(&xb1, 0, 1023);

         /*
          * Regular test2
          * set bit 2000, 2001, 2040
          * Next 1 in [0, 2048]          --> 2000
          * Next 1 in [2000, 2002]       --> 2000
          * Next 1 in [2002, 2040]       --> 2040
          * Next 1 in [2002, 2039]       --> none
          * Next 0 in [2000, 2048]       --> 2002
          * Next 0 in [2048, 2060]       --> 2048
          */
         xb_preload(GFP_KERNEL);
         assert(!xb_set_bit(&xb1, 2000));
         assert(!xb_set_bit(&xb1, 2001));
         assert(!xb_set_bit(&xb1, 2040));
         nbit = 0;
         assert(xb_find_set(&xb1, 2048, &nbit) == true);
         assert(nbit == 2000);
         assert(xb_find_set(&xb1, 2002, &nbit) == true);
         assert(nbit == 2000);
         nbit = 2002;
         assert(xb_find_set(&xb1, 2040, &nbit) == true);
         assert(nbit == 2040);
         nbit = 2002;
         assert(xb_find_set(&xb1, 2039, &nbit) == false);
         assert(nbit == 2002);
         nbit = 2000;
         assert(xb_find_zero(&xb1, 2048, &nbit) == true);
         assert(nbit == 2002);
         nbit = 2048;
         assert(xb_find_zero(&xb1, 2060, &nbit) == true);
         assert(nbit == 2048);
         xb_zero(&xb1, 0, 2048);
         nbit = 0;
         assert(xb_find_set(&xb1, 2048, &nbit) == false);
         assert(nbit == 0);
         xb_preload_end();

         /*
          * Overflow tests:
          * Set bit 1 and ULONG_MAX - 4
          * Next 1 in [0, ULONG_MAX]                     --> 1
          * Next 1 in [1, ULONG_MAX]                     --> 1
          * Next 1 in [2, ULONG_MAX]                     --> ULONG_MAX - 4
          * Next 1 in [ULONG_MAX - 3, 2]                 --> none
          * Next 0 in [ULONG_MAX - 4, ULONG_MAX]         --> ULONG_MAX - 3
          * Zero [ULONG_MAX - 4, ULONG_MAX]
          * Next 1 in [ULONG_MAX - 10, ULONG_MAX]        --> none
          * Next 1 in [ULONG_MAX - 1, 2]                 --> none
          * Zero [0, 1]
          * Next 1 in [0, 2]                             --> none
          */
         xb_preload(GFP_KERNEL);
         assert(!xb_set_bit(&xb1, 1));
         xb_preload_end();
         xb_preload(GFP_KERNEL);
         assert(!xb_set_bit(&xb1, ULONG_MAX - 4));
         nbit = 0;
         assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
         assert(nbit == 1);
         nbit = 1;
         assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
         assert(nbit == 1);
         nbit = 2;
         assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == true);
         assert(nbit == ULONG_MAX - 4);
         nbit++;
         assert(xb_find_set(&xb1, 2, &nbit) == false);
         assert(nbit == ULONG_MAX - 3);
         nbit--;
         assert(xb_find_zero(&xb1, ULONG_MAX, &nbit) == true);
         assert(nbit == ULONG_MAX - 3);
         xb_zero(&xb1, ULONG_MAX - 4, ULONG_MAX);
         nbit = ULONG_MAX - 10;
         assert(xb_find_set(&xb1, ULONG_MAX, &nbit) == false);
         assert(nbit == ULONG_MAX - 10);
         nbit = ULONG_MAX - 1;
         assert(xb_find_set(&xb1, 2, &nbit) == false);
         xb_zero(&xb1, 0, 1);
         nbit = 0;
         assert(xb_find_set(&xb1, 2, &nbit) == false);
         assert(nbit == 0);
         xb_preload_end();
         assert(xb_empty(&xb1));
}


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
