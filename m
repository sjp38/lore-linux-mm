Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0206B0006
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:04 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id g127so14748452qkc.14
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 00:20:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w198si4758968qkw.123.2018.02.27.00.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 00:20:03 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1R8JGMe144861
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:02 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gd23c3xhb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:02 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 27 Feb 2018 08:20:00 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] userfaultfd: non-cooperative: syncronous events
Date: Tue, 27 Feb 2018 10:19:49 +0200
Message-Id: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches add ability to generate userfaultfd events so that their
processing will be synchronized with the non-cooperative thread that caused
the event.

In the non-cooperative case userfaultfd resumes execution of the thread
that caused an event when the notification is read() by the uffd monitor.
In some cases, like, for example, madvise(MADV_REMOVE), it might be
desirable to keep the thread that caused the event suspended until the
uffd monitor had the event handled to avoid races between the thread that
caused the and userfaultfd ioctls.

Theses patches extend the userfaultfd API with an implementation of
UFFD_EVENT_REMOVE_SYNC that allows to keep the thread that triggered
UFFD_EVENT_REMOVE until the uffd monitor would not wake it explicitly.

Mike Rapoport (3):
  userfaultfd: introduce userfaultfd_init_waitqueue helper
  userfaultfd: non-cooperative: generalize wake key structure
  userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE

 fs/userfaultfd.c                 | 191 +++++++++++++++++++++++++++++----------
 include/uapi/linux/userfaultfd.h |  14 +++
 2 files changed, 158 insertions(+), 47 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
