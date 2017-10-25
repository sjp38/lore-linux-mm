Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD1C36B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:20:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 198so648645wmx.2
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 09:20:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 32si1914740edy.276.2017.10.25.09.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 09:20:10 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9PGHsKs099923
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:20:08 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dtuapsrhw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 12:20:08 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Oct 2017 17:20:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/3] userfaultfd: non-cooperative: syncronous events
Date: Wed, 25 Oct 2017 19:19:39 +0300
Message-Id: <1508948382-20951-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches add ability to generate userfaultfd events so that their
processing will be synchronized with the non-cooperative thread that caused
the event.

In the non-cooperative case userfaultfd resumes execution of the thread
that caused an event when the notification is read() by the uffd monitor.
In some cases, like, for example, madvise(MADV_REMOVE), it might be
desirable to keep the thread that caused the event suspended until the
uffd monitor had the event handled.

Theses patches extend the userfaultfd API with an implementation of
UFFD_EVENT_REMOVE_SYNC that allows to keep the thread that triggered
UFFD_EVENT_REMOVE until the uffd monitor would not wake it explicitly.

Mike Rapoport (3):
  userfaultfd: introduce userfaultfd_init_waitqueue helper
  userfaultfd: non-cooperative: generalize wake key structure
  userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE

 fs/userfaultfd.c                 | 158 ++++++++++++++++++++++++++++-----------
 include/uapi/linux/userfaultfd.h |  11 +++
 2 files changed, 124 insertions(+), 45 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
