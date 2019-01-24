Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3498E007C
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 04:04:03 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f17so2023586edm.20
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 01:04:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8-v6si4684509ejm.81.2019.01.24.01.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 01:04:01 -0800 (PST)
Date: Thu, 24 Jan 2019 10:04:00 +0100
From: Jan Kara <jack@suse.cz>
Subject: [LSF/MM TOPIC] get_user_pages() pins in file mappings
Message-ID: <20190124090400.GE12184@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>

This is a joint proposal with Dan Williams, John Hubbard, and Jérôme
Glisse.

Last year we've talked with Dan about issues we have with filesystems and
GUP [1]. The crux of the problem lies in the fact that there is no
coordination (or even awareness) between filesystem working on a page (such
as doing writeback) and GUP user modifying page contents and setting it
dirty. This can (and we have user reports of this) lead to data corruption,
kernel crashes, and other fun.

Since last year we have worked together on solving these problems and we
have explored couple dead ends as well as hopefully found solutions to some
of the partial problems. So I'd like to give some overview of where we
stand and what remains to be solved and get thoughts from wider community
about proposed solutions / problems to be solved.

In particular we hope to have reasonably robust mechanism of identifying
pages pinned by GUP (patches will be posted soon) - I'd like to run that by
MM folks (unless discussion happens on mailing lists before LSF/MM). We
also have ideas how filesystems should react to pinned page in their
writepages methods - there will be some changes needed in some filesystems
to bounce the page if they need stable page contents. So I'd like to
explain why we chose to do bouncing to fs people (i.e., why we cannot just
wait, skip the page, do something else etc.) to save us from the same
discussion with each fs separately and also hash out what the API for
filesystems to do this should look like. Finally we plan to keep pinned
page permanently dirty - again something I'd like to explain why we do this
and gather input from other people.

This should be ideally shared MM + FS session.

[1] https://lwn.net/Articles/753027/

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
