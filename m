Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 134048E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 15:17:49 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so25718973qtk.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 12:17:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si928964qve.86.2019.01.22.12.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 12:17:48 -0800 (PST)
Date: Tue, 22 Jan 2019 15:17:44 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: [LSF/MM TOPIC] Page flags, can we free up space ?
Message-ID: <20190122201744.GA3939@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

So lattely i have been looking at page flags and we are using 6 flags
for memory reclaim and compaction:

    PG_referenced
    PG_lru
    PG_active
    PG_workingset
    PG_reclaim
    PG_unevictable

On top of which you can add the page anonymous flag (anonymous or
share memory)
    PG_anon // does not exist, lower bit of page->mapping

And also the movable flag (which alias with KSM)
    PG_movable // does not exist, lower bit of page->mapping


So i would like to explore if there is a way to express the same amount
of information with less bits. My methodology is to exhaustively list
all the possible states (valid combination of above flags) and then to
see how we change from one state to another (what event trigger the change
like mlock(), page being referenced, ...) and under which rules (ie do we
hold the page lock, zone lock, ...).

My hope is that there might be someway to use less bits to express the
same thing. I am doing this because for my work on generic page write
protection (ie KSM for file back page) which i talk about last year and
want to talk about again ;) I will need to unalias the movable bit from
KSM bit.


Right now this is more a temptative ie i do not know if i will succeed,
in any case i can report on failure or success and discuss my finding to
get people opinions on the matter.


I think everyone interested in mm will be interested in this topic :)

Cheers,
Jérôme
