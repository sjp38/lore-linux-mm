Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 096F86B0031
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 22:21:22 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bz8so9199690wib.11
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 19:21:22 -0800 (PST)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id wi5si12289932wjc.79.2013.12.26.19.21.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Dec 2013 19:21:22 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id hq4so13910988wib.3
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 19:21:22 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 27 Dec 2013 14:21:21 +1100
Message-ID: <CAJrk0BuA2OTfMhmqZ-OFvtbdf_8+O3V77L0mDsoixN+t4A0ASA@mail.gmail.com>
Subject: [REGRESSION] [BISECTED] MM patch causes kernel lockup with 3.12 and acpi_backlight=vendor
From: Bradley Baetz <bbaetz@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b874d8299ae1804ee7b960c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org
Cc: hdegoede@redhat.com

--047d7b874d8299ae1804ee7b960c
Content-Type: text/plain; charset=ISO-8859-1

Hi,

I have a Dell laptop (Vostro 3560). When I boot Fedora 20 with the
acpi_backlight=vendor option, the kernel locks up hard during the boot
proces, when systemd runs udevadm trigger. This is a hard lockup -
magic-sysrq doesn't work, and neither does caps lock/vt-change/etc.

I've bisected this to:

commit 81c0a2bb515fd4daae8cab64352877480792b515
Author: Johannes Weiner <hannes@cmpxchg.org>
Date:   Wed Sep 11 14:20:47 2013 -0700

    mm: page_alloc: fair zone allocator policy

which seemed really unrelated, but I've confirmed that:

 - the commit before this patch doesn't cause the problem, and the commit
afterwrads does
 - reverting that patch from 3.12.0 fixes the problem
 - reverting that patch (and the partial revert
fff4068cba484e6b0abe334ed6b15d5a215a3b25) from master also fixes the problem
 - reverting that patch from the fedora 3.12.5-302.fc20 kernel fixes the
problem
 - applying that patch to 3.11.0 causes the problem

so I'm pretty sure that that is the patch that causes (or at least
triggers) this issue

I'm using the acpi_backlight option to get the backlight working - without
this the backlight doesn't work at all. Removing 'acpi_backlight=vendor'
(or blacklisting the dell-laptop module, which is effectively the same
thing) fixes the issue.

The lockup happens when systemd runs "udevadm trigger", not when the module
is loaded - I can reproduce the issue by booting into emergency mode,
remounting the filesystem as rw, starting up systemd-udevd and running
udevadm trigger manually. It dies a few seconds after loading the
dell-laptop module.

This happens even if I don't boot into X (using
systemd.unit=multi-user.target)

Triggering udev individually for each item doesn't trigger the issue ie:

for i in `udevadm --debug trigger --type=devices --action=add --dry-run
--verbose`; do echo $i; udevadm --debug trigger --type=devices --action=add
--verbose --parent-match=$i; sleep 1; done

works, so I haven't been able to work out what specific combination of
actions are causing this.

With the acpi_backlight option, I can manually read/write to the sysfs
dell-laptop backlight file, and it works (and changes the backlight as
expected)

This is 100% reproducible. I've also tested by powering off the laptop and
pulling the battery just in case one of the previous boots with the bisect
left the hardware in a strange state - no change.

I did successfully boot a 3.12 kernel on F19 (before I upgraded to F20), so
there's presumably something that F20 is doing differently. It was only one
boot though.

I reported this to fedora (
https://bugzilla.redhat.com/show_bug.cgi?id=1045807) but it looks like this
is an upstream issue so I was asked to report it here.

This is an 8-core single i7 cpu (one numa node) - its a laptop, so nothing
fancy. DMI data is attached to the fedora bug.

Bradley

--047d7b874d8299ae1804ee7b960c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi,<br><br></div><div>I have a Dell laptop (Vostro 35=
60). When I boot Fedora 20 with the acpi_backlight=3Dvendor option, the ker=
nel locks up hard during the boot proces, when systemd runs udevadm trigger=
. This is a hard lockup - magic-sysrq doesn&#39;t work, and neither does ca=
ps lock/vt-change/etc.<br>



<br>I&#39;ve bisected this to:<br><br>commit 81c0a2bb515fd4daae8cab64352877=
480792b515<br>Author: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.=
org" target=3D"_blank">hannes@cmpxchg.org</a>&gt;<br>Date:=A0=A0 Wed Sep 11=
 14:20:47 2013 -0700<br>

<br>=A0=A0=A0 mm: page_alloc: fair zone allocator policy<br><br><div>which =
seemed really unrelated, but I&#39;ve confirmed that:<br><br></div><div>=A0=
- the commit before this patch doesn&#39;t cause the problem, and the commi=
t afterwrads does<br>
</div><div>=A0- reverting that patch from 3.12.0 fixes the problem<br></div=
><div>=A0- reverting that patch (and the partial revert fff4068cba484e6b0ab=
e334ed6b15d5a215a3b25) from master also fixes the problem<br></div><div>=A0=
- reverting that patch from the fedora 3.12.5-302.fc20 kernel fixes the pro=
blem<br>

</div>=A0- applying that patch to 3.11.0 causes the problem<br><br></div><d=
iv>so I&#39;m pretty sure that that is the patch that causes (or at least t=
riggers) this issue<br></div><div><br></div><div>I&#39;m using the acpi_bac=
klight option to get the backlight working - without this the backlight doe=
sn&#39;t work at all. Removing &#39;acpi_backlight=3Dvendor&#39; (or blackl=
isting the dell-laptop module, which is effectively the same thing) fixes t=
he issue.<br>

</div><div><br></div><div>The lockup happens when systemd runs &quot;udevad=
m trigger&quot;, not when the module is loaded - I can reproduce the issue =
by booting into emergency mode, remounting the filesystem as rw, starting u=
p systemd-udevd and running udevadm trigger manually. It dies a few seconds=
 after loading the dell-laptop module.<br>

<br></div><div>This happens even if I don&#39;t boot into X (using systemd.=
unit=3Dmulti-user.target)<br></div><div>

<br></div><div>Triggering udev individually for each item doesn&#39;t trigg=
er the issue ie:<br></div><div><br>for i in `udevadm --debug trigger --type=
=3Ddevices --action=3Dadd --dry-run --verbose`; do echo $i; udevadm --debug=
 trigger --type=3Ddevices --action=3Dadd --verbose --parent-match=3D$i; sle=
ep 1; done<br>

<br></div><div>works, so I haven&#39;t been able to work out what specific =
combination of actions are causing this.<br></div><div><div><br></div>With =
the acpi_backlight option, I can manually=20
read/write to the sysfs dell-laptop backlight file, and it works (and=20
changes the backlight as expected)</div><div><br></div><div>This is 100% re=
producible. I&#39;ve also tested by powering off the laptop and pulling the=
 battery just in case one of the previous boots with the bisect left the ha=
rdware in a strange state - no change.<br>

</div><div><br></div><div>I did successfully boot a 3.12 kernel on F19 (bef=
ore I upgraded to F20), so there&#39;s presumably something that F20 is doi=
ng differently. It was only one boot though.<br></div><div><br>I reported t=
his to fedora (<a href=3D"https://bugzilla.redhat.com/show_bug.cgi?id=3D104=
5807" target=3D"_blank">https://bugzilla.redhat.com/show_bug.cgi?id=3D10458=
07</a>) but it looks like this is an upstream issue so I was asked to repor=
t it here.<br>



</div><div><br></div><div>This is an 8-core single i7 cpu (one numa node) -=
 its a laptop, so nothing fancy. DMI data is attached to the fedora bug.<br=
></div><div><br></div><div>Bradley<br></div></div>

--047d7b874d8299ae1804ee7b960c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
