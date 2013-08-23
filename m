Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7C9E86B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:57:37 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id l13so322292qcy.39
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:57:36 -0700 (PDT)
Date: Fri, 23 Aug 2013 10:57:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130823145732.GC3277@htj.dyndns.org>
References: <1377202292.10300.693.camel@misato.fc.hp.com>
 <20130822202158.GD3490@mtj.dyndns.org>
 <1377205598.10300.715.camel@misato.fc.hp.com>
 <20130822212111.GF3490@mtj.dyndns.org>
 <1377209861.10300.756.camel@misato.fc.hp.com>
 <20130823130440.GC10322@mtj.dyndns.org>
 <3ee58764-21c2-4df4-9353-54799a6a3d7b@email.android.com>
 <20130823141924.GA3277@htj.dyndns.org>
 <bf688aac-4080-4ac6-83cd-fd66cef6ce1a@email.android.com>
 <20130823143507.GB3277@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130823143507.GB3277@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Aug 23, 2013 at 10:35:07AM -0400, Tejun Heo wrote:
> Yeah, it's true that MTRRs are nasty.  On the other hand, we've been
> doing that for over a decade and are still doing it anyway if I'm not
> mistaken.  It probably isn't a big difference but it's still a bit sad
> that this is likely causing small performance regression out in the
> wild.

Just went over the processor manual and it doesn't seem like doing the
above would be a good idea.


  System Programming Guide, Part 1

  11.11.9 Large Page Size Considerations

 ... 
 Because the memory type for a large page is cached in the TLB, the
 processor can behave in an undefined manner if a large page is mapped
 to a region of memory that MTRRs have mapped with multiple memory
 types.
 ...
 If a large page maps to a region of memory containing different
 MTRR-defined memory types, the PCD and PWT flags in the page-table
 entry should be set for the most conservative memory type for that
 range. For example, a large page used for memory mapped I/O and
 regular memory 11-48 Vol. 3A MEMORY CACHE CONTROL
 ...

 The Pentium 4, Intel Xeon, and P6 family processors provide special
 support for the physical memory range from 0 to 4 MBytes,
 ...
 Here, the processor maps the memory range as multiple 4-KByte pages
 within the TLB. This operation insures correct behavior at the cost
 of performance. To avoid this performance penalty, operating-system
 software should reserve the large page option for regions of memory
 at addresses greater than or equal to 4 MBytes.

So, yeah, the current behavior seems like the right thing to do.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
