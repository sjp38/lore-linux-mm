Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5B68E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:45:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so6720091ede.14
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:45:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor29807334edd.12.2019.01.28.06.45.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:45:14 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages fallouts.
Date: Mon, 28 Jan 2019 15:45:04 +0100
Message-Id: <20190128144506.15603-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>, Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
Mikhail has posted fixes for the two bugs quite some time ago [1]. I
have pushed back on those fixes because I believed that it is much
better to plug the problem at the initialization time rather than play
whack-a-mole all over the hotplug code and find all the places which
expect the full memory section to be initialized. We have ended up with
2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
memory section") merged and cause a regression [2][3]. The reason is
that there might be memory layouts when two NUMA nodes share the same
memory section so the merged fix is simply incorrect.

In order to plug this hole we really have to be zone range aware in
those handlers. I have split up the original patch into two. One is
unchanged (patch 2) and I took a different approach for `removable'
crash. It would be great if Mikhail could test it still works for his
memory layout.

[1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
[2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
[3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
