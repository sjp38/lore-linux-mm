Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D6F546B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 16:49:57 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Date: Mon, 12 Aug 2013 20:49:42 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F31CB74A1@ORSMSX106.amr.corp.intel.com>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130812145016.GI15892@htj.dyndns.org> <5208FBBC.2080304@zytor.com>
 <20130812152343.GK15892@htj.dyndns.org> <52090D7F.6060600@gmail.com>
 <20130812164650.GN15892@htj.dyndns.org> <52092811.3020105@gmail.com>
 <20130812202029.GB8288@mtj.dyndns.org>
In-Reply-To: <20130812202029.GB8288@mtj.dyndns.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Tang Chen <imtangchen@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>, "Moore, Robert" <robert.moore@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "trenn@suse.de" <trenn@suse.de>, "yinghai@kernel.org" <yinghai@kernel.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>

>> This point, I don't quite agree. What you said is highly likely, but
>> not definitely. Users may find they lost hotpluggable memory.
>
> I'm having difficult time buying that.  NUMA node granularity is
> usually pretty large - it's in the range of gigabytes.  By comparison,
> the area occupied by the kernel image is *tiny* and it's just highly
> unlikely that allocating a bit more memory afterwards would lead to
> any meaningful difference in hotunplug support.  The amount of memory
> we're talking about is likely to be less than a meg, right?

Pretty safe to assume double-digit gigabytes for a removable chunk
(8G DIMMs are fast becoming standard, and there are typically 4 channels
to populate with at least one DIMM each). 16G and 32G DIMMs are pricey,
but moving in too.  So I don't think we need to assume that early allocatio=
ns
are limited to some tiny amount measured in single digit megabytes. We'd
be safe even with some small number of gigabytes.

> I don't think it's a better solution.  It's fragile and fiddly and
> without much, if any, additional benefit.  Why should we do that when
> we can almost trivially solve the problem almost in memblock proper in
> a way which is completely firmware-agnostic?

So we do need to make sure that early memory allocations do happen from
the free areas adjacent to the kernel - and document that as a requirement
so we don't have people coming along later with a "allocate from top of mem=
ory
downwards" or other strategy that would break this assumption.  If we do th=
at,
then I think I stand with Tejun that there is little benefit to parsing the=
 SRAT
earlier.

The only fly I see in the ointment here is the crazy fragmentation of physi=
cal
memory below 4G on X86 systems.  Typically it will all be on the same node.
But I don't know if there is any specification that requires it be that way=
. If some
"helpful" OEM decided to make some "lowmem" (below 4G) be available on
every node, they might in theory do something truly awesomely strange.  But
even here - the granularity of such mappings tends to be large enough that
the "allocate near where the kernel was loaded" should still work to make t=
hose
allocations be on the same node for the "few megabytes" level of allocation=
s.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
