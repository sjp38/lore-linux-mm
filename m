Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 252FC6B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 19:03:12 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id mc6so8968127lab.28
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:03:11 -0800 (PST)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id b8si4861540lah.38.2014.02.13.16.03.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 16:03:10 -0800 (PST)
Received: by mail-la0-f46.google.com with SMTP id b8so8698758lan.19
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:03:09 -0800 (PST)
MIME-Version: 1.0
From: Pradeep Sawlani <pradeep.sawlani@gmail.com>
Date: Thu, 13 Feb 2014 16:02:49 -0800
Message-ID: <CAMrOTPiZvfErHrmuDSgUeq5R5M-6xqgYXLGj8a0BjEvMmRkzkg@mail.gmail.com>
Subject: KSM on Android
Content-Type: multipart/alternative; boundary=001a113498d8ff051004f25287bf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, hughd@google.com
Cc: linux-mm@kvack.org

--001a113498d8ff051004f25287bf
Content-Type: text/plain; charset=ISO-8859-1

Hello

In pursuit of saving memory on Android, I started experimenting with Kernel
Same Page Merging(KSM).
Number of pages shared because of KSM is reported by
/sys/kernel/mm/pages_sharing.
Documentation/vm/ksm.txt explains this as:

"pages_sharing    - how many more sites are sharing them i.e. how much
saved"

After enabling KSM on Android device, this number was reported as 19666
pages.
Obvious optimization is to find out source of sharing and see if we can
avoid duplicate pages at first place.
In order to collect the data needed, It needed few
modifications(trace_printk) statement in mm/ksm.c.
Data should be collected from second cycle because that's when ksm starts
merging
pages. First KSM cycle is only used to calculate the checksum, pages are
added to
unstable tree and eventually moved to stable tree after this.

After analyzing data from second KSM cycle, few things which stood out:
1.  In the same cycle, KSM can scan same page multiple times. Scanning a
page involves
    comparing page with pages in stable tree, if no match is found checksum
is calculated.
    From the look of it, it seems to be cpu intensive operation and impacts
dcache as well.

2.  Same page which is already shared by multiple process can be replaced
by KSM page.
    In this case, let say a particular page is mapped 24 times and is
replaced by KSM page then
    eventually all 24 entries will point to KSM page. pages_sharing will
account for all 24 pages.
    so pages _sharing does not actually report amount of memory saved. From
the above example actual
    savings is one page.

Both cases happen very often with Android because of its architecture -
Zygote spawning(fork) multiple
applications. To calculate actual savings, we should account for same
page(pfn)replaced by same KSM page only once.
In the case 2 example, page_sharing should account only one page.
After recalculating memory saving comes out to be 8602 pages (~34MB).

I am trying to find out right solution to fix pages_sharing and eventually
optimize KSM to scan page
once even if it is mapped multiple times.

Comments?

Thanks,
Pradeep

--001a113498d8ff051004f25287bf
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hello</div><div><br></div><div>In pursuit of saving m=
emory on Android, I started experimenting with Kernel Same Page Merging(KSM=
).</div><div>Number of pages shared because of KSM is reported by /sys/kern=
el/mm/pages_sharing.<br>

</div><div>Documentation/vm/ksm.txt explains this as:<br></div><div><br></d=
iv><div>&quot;pages_sharing =A0 =A0- how many more sites are sharing them i=
.e. how much saved&quot;<br></div><div><br></div><div>After enabling KSM on=
 Android device, this number was reported as 19666 pages.</div>

<div>Obvious optimization is to find out source of sharing and see if we ca=
n avoid duplicate pages at first place.<br></div><div>In order to collect t=
he data needed, It needed few modifications(trace_printk) statement in mm/k=
sm.c.<br>

</div><div>Data should be collected from second cycle because that&#39;s wh=
en ksm starts merging<br></div><div>pages. First KSM cycle is only used to =
calculate the checksum, pages are added to<br></div><div>unstable tree and =
eventually moved to stable tree after this.=A0<br>

</div><div><br></div><div>After analyzing data from second KSM cycle, few t=
hings which stood out:</div><div>1. =A0In the same cycle, KSM can scan same=
 page multiple times. Scanning a page involves<br></div><div>=A0 =A0 compar=
ing page with pages in stable tree, if no match is found checksum is calcul=
ated.</div>

<div>=A0 =A0 From the look of it, it seems to be cpu intensive operation an=
d impacts dcache as well.</div><div><br></div><div>2. =A0Same page which is=
 already shared by multiple process can be replaced by KSM page.</div><div>=
=A0 =A0 In this case, let say a particular page is mapped 24 times and is r=
eplaced by KSM page then</div>

<div>=A0 =A0 eventually all 24 entries will point to KSM page. pages_sharin=
g will account for all 24 pages.</div><div>=A0 =A0 so pages _sharing does n=
ot actually report amount of memory saved. From the above example actual</d=
iv>
<div>
=A0 =A0 savings is one page.</div><div><br></div><div>Both cases happen ver=
y often with Android because of its architecture - Zygote spawning(fork) mu=
ltiple</div><div>applications. To calculate actual savings, we should accou=
nt for same page(pfn)replaced by same KSM page only once.</div>

<div>In the case 2 example, page_sharing should account only one page.=A0</=
div><div>After recalculating memory saving comes out to be 8602 pages (~34M=
B).=A0</div><div><br></div><div>I am trying to find out right solution to f=
ix pages_sharing and eventually optimize KSM to scan page=A0</div>

<div>once even if it is mapped multiple times.</div><div><br></div><div>Com=
ments?</div><div><br></div><div>Thanks,</div><div>Pradeep</div><div><br></d=
iv></div>

--001a113498d8ff051004f25287bf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
