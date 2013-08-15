Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 8A8FA6B0037
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 15:07:27 -0400 (EDT)
Message-ID: <1376593564.10300.446.camel@misato.fc.hp.com>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 15 Aug 2013 13:06:04 -0600
In-Reply-To: <520ADBBA.10501@cn.fujitsu.com>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
	 <20130812145016.GI15892@htj.dyndns.org> <5208FBBC.2080304@zytor.com>
	 <20130812152343.GK15892@htj.dyndns.org> <52090D7F.6060600@gmail.com>
	 <20130812164650.GN15892@htj.dyndns.org> <5209CEC1.8070908@cn.fujitsu.com>
	 <520A02DE.1010908@cn.fujitsu.com>
	 <CAE9FiQV2-OOvHZtPYSYNZz+DfhvL0e+h2HjMSW3DyqeXXvdJkA@mail.gmail.com>
	 <520ADBBA.10501@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Tang Chen <imtangchen@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J.
 Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Luck, Tony
 (tony.luck@intel.com)" <tony.luck@intel.com>

On Wed, 2013-08-14 at 09:22 +0800, Tang Chen wrote:
> On 08/14/2013 06:33 AM, Yinghai Lu wrote:
> ......
> >
> >>     relocate_initrd()
> >
> > size could be very big, like several hundreds mega bytes.
> > should be anywhere, but will be freed after booting.
> >
> > ===>  so we should not limit it to near kernel range.
> >
> >>     acpi_initrd_override()
> >
> > should be 64 * 10 about 1M.
> >
> >>     reserve_crashkernel()
> >
> > could be under 4G, or above 4G.
> > size could be 512M or 8G whatever.
> >
> > looks like
> > should move down relocated_initrd and reserve_crashkernel.
> 
> OK, will try to do this.
> 
> Thank you for the explanation. :)

So, we still need reordering, and put a new requirement that all earlier
allocations must be small...

I think the root of this issue is that ACPI init point is not early
enough in the boot sequence.  If it were much earlier already, the whole
thing would have been very simple.  We are now trying to workaround this
issue in the mblock code (which itself is a fine idea), but this ACPI
issue still remains and similar issues may come up again in future.  

For instance, ACPI SCPR/DBGP/DBG2 tables allow the OS to initialize
serial console/debug ports at early boot time.  The earlier it can be
initialized, the better this feature will be.  These tables are not
currently used by Linux due to a licensing issue, but it could be
addressed some time soon.  As platforms becoming more complex & legacy
free, the needs of ACPI tables will increase.

I think moving up the ACPI init point earlier is a good direction.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
