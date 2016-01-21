Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4D86B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 09:28:13 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id 123so176494109wmz.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 06:28:13 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id w130si47626730wma.82.2016.01.21.06.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 06:28:11 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id l65so11232632wmf.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 06:28:11 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 22 Jan 2016 00:28:10 +1000
Message-ID: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com>
Subject: [REGRESSION] [BISECTED] kswapd high CPU usage
From: Nalorokk <nalorokk@gmail.com>
Content-Type: multipart/alternative; boundary=001a11444b5884a08f0529d8e92c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, oleksandr@natalenko.name

--001a11444b5884a08f0529d8e92c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

It appears that kernels newer than 4.1 have kswapd-related bug resulting in
high CPU usage. CPU 100% usage could last for several minutes or several
days, with CPU being busy entirely with serving kswapd. It happens usually
after server being mostly idle, sometimes after days, sometimes after weeks
of uptime. But the issue appears much sooner if the machine is loaded with
something like building a kernel.

Here are the graphs of CPU load: first
<http://i.piccy.info/i9/9ee6c0620c9481a974908484b2a52a0f/1453384595/44012/9=
94698/cpu_month.png>,
second
<http://i.piccy.info/i9/7c97c2f39620bb9d7ea93096312dbbb6/1453384649/41222/9=
94698/cpu_year.png>.
Perf top output is here <http://pastebin.com/aRzTjb2x>as well.

To find the cause of this problem I've started with the fact that the issue
appeared after 4.1 kernel update. Then I performed longterm test of 3.18,
and discovered that 3.18 is unaffected by this bug. Then I did some tests
of 4.0 to confirm that this version behaves well too.

Then I performed git bisect from tag v4.0 to v4.1-rc1 and found exact
commits that seem to be reason of high CPU usage.

The first really "bad" commit is 79553da293d38d63097278de13e28a3b371f43c1.
2 previous commits cause weird behavior as well resulting in kswapd
consuming more CPU than unaffected kernels, but not that much as the commit
pointed above. I believe those commits are related to the same mm tree
merge.

I tried to add transparent_hugepage=3Dnever to kernel boot parameters, but =
it
did not change anything. Changing allocator to SLAB from SLUB alters
behavior and makes CPU load lower, but don't solve a problem at all.

Here <https://bugzilla.kernel.org/show_bug.cgi?id=3D110501>is kernel bugzil=
la
bugreport as well.

Ideas? =E2=80=8B

--001a11444b5884a08f0529d8e92c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><p dir=3D"ltr">It appears that kernels newer than 4.1=
 have kswapd-related bug resulting in high CPU usage. CPU 100% usage could =
last for several minutes or several days, with CPU being busy entirely with=
 serving kswapd. It happens usually after server being mostly idle, sometim=
es after days, sometimes after weeks of uptime. But the issue appears much =
sooner if the machine is loaded with something like building a kernel.</p><=
p dir=3D"ltr">Here are the graphs of CPU load: <a href=3D"http://i.piccy.in=
fo/i9/9ee6c0620c9481a974908484b2a52a0f/1453384595/44012/994698/cpu_month.pn=
g">first</a>, <a href=3D"http://i.piccy.info/i9/7c97c2f39620bb9d7ea93096312=
dbbb6/1453384649/41222/994698/cpu_year.png">second</a>. Perf top output is =
<a href=3D"http://pastebin.com/aRzTjb2x">here </a>as well.</p><p dir=3D"ltr=
">To find the cause of this problem I&#39;ve started with the fact that the=
 issue appeared after 4.1 kernel update. Then I performed longterm test of =
3.18, and discovered that 3.18 is unaffected by this bug. Then I did some t=
ests of 4.0 to confirm that this version behaves well too.</p><p dir=3D"ltr=
">Then I performed git bisect from tag v4.0 to v4.1-rc1 and found exact com=
mits that seem to be reason of high CPU usage.</p><p dir=3D"ltr">The first =
really &quot;bad&quot; commit is 79553da293d38d63097278de13e28a3b371f43c1. =
2 previous commits cause weird behavior as well resulting in kswapd consumi=
ng more CPU than unaffected kernels, but not that much as the commit pointe=
d above. I believe those commits are related to the same mm tree merge.</p>=
<p dir=3D"ltr">I tried to add transparent_hugepage=3Dnever to kernel boot p=
arameters, but it did not change anything. Changing allocator to SLAB from =
SLUB alters behavior and makes CPU load lower, but don&#39;t solve a proble=
m at all.</p><p dir=3D"ltr"><a href=3D"https://bugzilla.kernel.org/show_bug=
.cgi?id=3D110501">Here </a>is kernel bugzilla bugreport as well.</p><p dir=
=3D"ltr">Ideas? =E2=80=8B</p></div></div>

--001a11444b5884a08f0529d8e92c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
