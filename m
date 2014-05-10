Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BEDA86B0036
	for <linux-mm@kvack.org>; Sat, 10 May 2014 02:11:34 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so5289077pad.18
        for <linux-mm@kvack.org>; Fri, 09 May 2014 23:11:34 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id rk7si3963794pab.174.2014.05.09.23.11.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 09 May 2014 23:11:33 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N5C0005UH77Z1D0@mailout2.samsung.com> for
 linux-mm@kvack.org; Sat, 10 May 2014 15:11:31 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
 <20140505152014.GA8551@cerebellum.variantweb.net>
 <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
 <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
 <1399328550.2646.5.camel@buesod1.americas.hpqcorp.net>
 <000001cf69c9$5776f330$0664d990$%yang@samsung.com>
 <20140507085743.GA31680@bbox>
 <CAL1ERfOXNrfKqMVs-Yz8yJjKKU3L5fjUEOb0Aeyqc37py-BWEg@mail.gmail.com>
 <CAAmzW4Pn2VUEnQ8FyOaBffqfUiHt6ocLEEvyaJrSKmTjaNp_wQ@mail.gmail.com>
 <20140508062418.GF5282@bbox>
In-reply-to: <20140508062418.GF5282@bbox>
Subject: RE: [PATCH] zram: remove global tb_lock by using lock-free CAS
Date: Sat, 10 May 2014 14:10:08 +0800
Message-id: <000001cf6c16$afe73800$0fb5a800$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=Windows-1252
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Joonsoo Kim' <js1304@gmail.com>
Cc: 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Davidlohr Bueso' <davidlohr@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Seth Jennings' <sjennings@variantweb.net>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Heesub Shin' <heesub.shin@samsung.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Thu, May 8, 2014 at 2:24 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Wed, May 07, 2014 at 11:52:59PM +0900, Joonsoo Kim wrote:
>> >> Most popular use of zram is the in-memory swap for small embedded system
>> >> so I don't want to increase memory footprint without good reason although
>> >> it makes synthetic benchmark. Alhought it's 1M for 1G, it isn't small if we
>> >> consider compression ratio and real free memory after boot
>>
>> We can use bit spin lock and this would not increase memory footprint for 32 bit
>> platform.
>
> Sounds like a idea.
> Weijie, Do you mind testing with bit spin lock?

Yes, I re-test them.
This time, I test each case 10 times, and take the average(KS/s).
(the test machine and method are same like previous mail's)

Iozone test result:

      Test       BASE     CAS   spinlock   rwlock  bit_spinlock
--------------------------------------------------------------
 Initial write  1381094   1425435   1422860   1423075   1421521
       Rewrite  1529479   1641199   1668762   1672855   1654910
          Read  8468009  11324979  11305569  11117273  10997202
       Re-read  8467476  11260914  11248059  11145336  10906486
  Reverse Read  6821393   8106334   8282174   8279195   8109186
   Stride read  7191093   8994306   9153982   8961224   9004434
   Random read  7156353   8957932   9167098   8980465   8940476
Mixed workload  4172747   5680814   5927825   5489578   5972253
  Random write  1483044   1605588   1594329   1600453   1596010
        Pwrite  1276644   1303108   1311612   1314228   1300960
         Pread  4324337   4632869   4618386   4457870   4500166

Fio test result:

    Test     base     CAS    spinlock    rwlock  bit_spinlock
-------------------------------------------------------------
seq-write   933789   999357   1003298    995961   1001958
 seq-read  5634130  6577930   6380861   6243912   6230006
   seq-rw  1405687  1638117   1640256   1633903   1634459
  rand-rw  1386119  1614664   1617211   1609267   1612471


The base is v3.15.0-rc3, the others are per-meta entry lock.
Every optimization method shows higher performance than the base, however,
it is hard to say which method is the most appropriate.

To bit_spinlock, the modified code is mainly like this:

+#define ZRAM_FLAG_SHIFT 16
+
enum zram_pageflags {
 	/* Page consists entirely of zeros */
-	ZRAM_ZERO,
+	ZRAM_ZERO = ZRAM_FLAG_SHIFT + 1,
+	ZRAM_ACCESS,
 
 	__NR_ZRAM_PAGEFLAGS,
 };
 
 /* Allocated for each disk page */
 struct table {
 	unsigned long handle;
-	u16 size;	/* object size (excluding header) */
-	u8 flags;
+	unsigned long value;
 } __aligned(4);

The lower ZRAM_FLAG_SHIFT bits of table.value is size, the higher bits
is for zram_pageflags. By this means, it doesn't increase any memory
overhead on both 32-bit and 64-bit system.

Any complaint or suggestions are welcomed.

>>
>> Thanks.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
