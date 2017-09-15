Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A22416B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 20:16:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f84so1457906pfj.0
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 17:16:33 -0700 (PDT)
Received: from rcdn-iport-7.cisco.com (rcdn-iport-7.cisco.com. [173.37.86.78])
        by mx.google.com with ESMTPS id k1si5361065pld.524.2017.09.14.17.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 17:16:32 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Taras Kondratiuk <takondra@cisco.com>
Message-ID: <150543458765.3781.10192373650821598320@takondra-t460s>
Subject: Detecting page cache trashing state
Date: Thu, 14 Sep 2017 17:16:27 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org

Hi

In our devices under low memory conditions we often get into a trashing
state when system spends most of the time re-reading pages of .text
sections from a file system (squashfs in our case). Working set doesn't
fit into available page cache, so it is expected. The issue is that
OOM killer doesn't get triggered because there is still memory for
reclaiming. System may stuck in this state for a quite some time and
usually dies because of watchdogs.

We are trying to detect such trashing state early to take some
preventive actions. It should be a pretty common issue, but for now we
haven't find any existing VM/IO statistics that can reliably detect such
state.

Most of metrics provide absolute values: number/rate of page faults,
rate of IO operations, number of stolen pages, etc. For a specific
device configuration we can determine threshold values for those
parameters that will detect trashing state, but it is not feasible for
hundreds of device configurations.

We are looking for some relative metric like "percent of CPU time spent
handling major page faults". With such relative metric we could use a
common threshold across all devices. For now we have added such metric
to /proc/stat in our kernel, but we would like to find some mechanism
available in upstream kernel.

Has somebody faced similar issue? How are you solving it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
