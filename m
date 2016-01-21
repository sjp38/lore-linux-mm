Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 613A56B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 09:37:09 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id r129so174828388wmr.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 06:37:09 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id h62si4588042wmh.51.2016.01.21.06.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 06:37:08 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id u188so11333358wmu.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 06:37:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com>
References: <CAPKbV49wfVWqwdgNu9xBnXju-4704t2QF97C+6t3aff_8bVbdA@mail.gmail.com>
Date: Fri, 22 Jan 2016 00:37:07 +1000
Message-ID: <CAPKbV48YOF4OSMqWpeUUM6MPGCXG5NSgVTc51cmd28UZO_f3vw@mail.gmail.com>
Subject: Fwd: [REGRESSION] [BISECTED] kswapd high CPU usage
From: Nalorokk <nalorokk@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stefan Strogin <s.strogin@partner.samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, oleksandr@natalenko.name

It appears that kernels newer than 4.1 have kswapd-related bug
resulting in high CPU usage. CPU 100% usage could last for several
minutes or several days, with CPU being busy entirely with serving
kswapd. It happens usually after server being mostly idle, sometimes
after days, sometimes after weeks of uptime. But the issue appears
much sooner if the machine is loaded with something like building a
kernel.

Here are the graphs of CPU load: first [1], second [2]. Perf top
output is here [3] as well.

To find the cause of this problem I've started with the fact that the
issue appeared after 4.1 kernel update. Then I performed longterm test
of 3.18, and discovered that 3.18 is unaffected by this bug. Then I
did some tests of 4.0 to confirm that this version behaves well too.

Then I performed git bisect from tag v4.0 to v4.1-rc1 and found exact
commits that seem to be reason of high CPU usage.

The first really "bad" commit is
79553da293d38d63097278de13e28a3b371f43c1. 2 previous commits cause
weird behavior as well resulting in kswapd consuming more CPU than
unaffected kernels, but not that much as the commit pointed above. I
believe those commits are related to the same mm tree merge.

I tried to add transparent_hugepage=never to kernel boot parameters,
but it did not change anything. Changing allocator to SLAB from SLUB
alters behavior and makes CPU load lower, but don't solve a problem at
all.

Here [4] is kernel bugzilla bugreport as well.

Ideas?

[1] http://i.piccy.info/i9/9ee6c0620c9481a974908484b2a52a0f/1453384595/44012/994698/cpu_month.png
[2] http://i.piccy.info/i9/7c97c2f39620bb9d7ea93096312dbbb6/1453384649/41222/994698/cpu_year.png
[3] http://pastebin.com/aRzTjb2x
[4] https://bugzilla.kernel.org/show_bug.cgi?id=110501

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
