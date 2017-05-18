Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 65D25831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 09:35:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 196so9074016wmk.9
        for <linux-mm@kvack.org>; Thu, 18 May 2017 06:35:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c31si5790467eda.24.2017.05.18.06.35.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 06:35:08 -0700 (PDT)
Date: Thu, 18 May 2017 15:28:18 +0200
From: Jan Kara <jack@suse.cz>
Subject: Strange condition in invalidate_mapping_pages()
Message-ID: <20170518132818.GA16430@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org

Hi Kirill,

in commit fc127da085c26 "truncate: handle file thp" you've added the
following to invalidate_mapping_pages():

          /* Middle of THP: skip */
          if (PageTransTail(page)) {
                  unlock_page(page);
                  continue;
          } else if (PageTransHuge(page)) {
                  index += HPAGE_PMD_NR - 1;
                  i += HPAGE_PMD_NR - 1;
                  /* 'end' is in the middle of THP */
                  if (index ==  round_down(end, HPAGE_PMD_NR))
                          continue;
          }

Now how can ever condition "if (index ==  round_down(end,
HPAGE_PMD_NR))" be true? We have just added HPAGE_PMD_NR - 1 to 'index'
so it will not be a multiple of HPAGE_PMD_NR. Presumably you wanted to
check whether the current THP is the one containing 'end' here which would
be something like 'round_down(index, HPAGE_PMD_NR) == round_down(end,
HPAGE_PMD_NR)' but then I still miss why you'd like to avoid invalidating
the partial THP at the end of file... Can you please enlighten me? Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
