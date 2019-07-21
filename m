Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04E3BC76195
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D852208E4
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WVSiCWvN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D852208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C8E78E0005; Sun, 21 Jul 2019 11:58:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07AAE6B000D; Sun, 21 Jul 2019 11:58:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED1198E0005; Sun, 21 Jul 2019 11:58:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5E3A6B000C
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 11:58:19 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so15111503pgv.0
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 08:58:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=DDH0NhE6n6ta7EYCQyM5rU/FRAaVDyWq9ScZ3NSNGqI=;
        b=OiGdvf++AOvQbaLyYzntFsNyqG0xXprFJPOfAb61aphiW8yL2vSKUFzEe5LVBPsNrM
         KFuqhlr6I+00lVRkinv/bmiQSwAN0OmqVMtNV956OVGjSJpXJJ1cfjNAlH4D0rT/cX4/
         TBp3WJ7f5fae4j+7A55j+wfobMPUbTXl43KF6YYfvz2XTkkUhFIJTlwoWigePORGjzcb
         y1cCucblUdQrfNBhmPxStsYBxjJwrCm95WQ8Qtcmzr4bDrvLb+YkMCpf6MfUrLdZRkdL
         89/hN2VtCsR//OVOJLv84wUc+HJnk6E9Ot7j4xHeo9W3bnobyeYdIuoabhupU7gzDb00
         cHXA==
X-Gm-Message-State: APjAAAVsCVlqSgHuquJkwIMv+KZx/7FafpSPCQN7EmRGPoUWiiiwUkLJ
	B7PyBuuU3EMJKQ+LwNvkikFBRlhAXIVWkwc06/ekG5URgklOhImmt+RI6saCD8lusWerfRvJoD/
	fCRgyCRtTLlWdlpBwAtUaGnocr4ewDzIuZ8EwpnudeWNpeHTr7xLwkVg6+6ZkYMIKSg==
X-Received: by 2002:a63:79c4:: with SMTP id u187mr2581906pgc.49.1563724699251;
        Sun, 21 Jul 2019 08:58:19 -0700 (PDT)
X-Received: by 2002:a63:79c4:: with SMTP id u187mr2581852pgc.49.1563724698412;
        Sun, 21 Jul 2019 08:58:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563724698; cv=none;
        d=google.com; s=arc-20160816;
        b=iK7aMSXxtNaFbGqKpc1QHOyl5qynrVUxKHujopINeMG89V8+xD7Xm+XhlN9rq31DnJ
         oTSWvMIcC9Tm4NzlAWaLKs72BxbULyvxxPEBWBDn7tkbEwNUDzhiCu65l30nYOjxw/Yi
         2hU5ikv8DA57efNdZK0AZzALV6B9MZ+bfGi2koDslp8ZaySH4fjxjldpXN/xMCRATHP9
         jHMVsa4QYtTn4lp0JOXj2wB31I6bYSm+IWygYqbkjgUQGk8eMQFBPNrwsfvf2HTkO2P/
         pqu2R7OGmYZ2jrW0ECElyHtkBwkjBMAM0tvdPCzUhaV9Hf138ZWzoO3oJb4VJ6ZXPRpi
         TUmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=DDH0NhE6n6ta7EYCQyM5rU/FRAaVDyWq9ScZ3NSNGqI=;
        b=aLgLR4sQ8dShMaKPUtFcCAED+GAHXcVzkqtH0/wt0QN5iWs4MJQSerlbNEwqH4x2xQ
         1aNNLyq5M9ouxq5LFkaEL8c6K9jqLy8JHh57hPPonCH9IyrUcpYwxqPpog8euJeECNcc
         4yRQgavxssr5bAFQfEOqzzbF4rnzN+dJwxzAGCiFMOk5WfAmzyr9CFAujf8J6MvB8q8X
         qbPp6l52BjzG0aomT5Mrhu6cADMh3v5SS1uEOfSovIlmrL8auDWUVfag2NqXLnHAILxr
         EPLY9FfrDFSlxwqIxmxkTZ86MMCeamrF846qHwVak6/G45X4+5/65G0fz1tnLJTATO4k
         93sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WVSiCWvN;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h63sor45856599pjb.6.2019.07.21.08.58.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 08:58:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WVSiCWvN;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DDH0NhE6n6ta7EYCQyM5rU/FRAaVDyWq9ScZ3NSNGqI=;
        b=WVSiCWvN4Myy+QbG5zDlacgHt8OFkZAobDbyEG2NtCptrqKyxBXkLzeAvEcndlSzhv
         IvqnL+fkctBEMDb8Xy9Gl9WTBwpmRbs1nbFeFi3PZJ3dosmh8U32mR+Srw8bUUCejuIh
         WpS1r7VN/MSnITGRvwwYs9yd/ceeoVTyv2G0UhJiMycDTpWQjvOlBZmL0raPXDkNdhEt
         xFVhzZpjxxFlreExaKYDYNgGXEosh9bD5S8lpPPhUIFuhgJDu/2zd1PMqSc+jVJjW2io
         EbL+owYYNnvARuc7fmsD4zgLnlu43qPiWhdTZAvv+jF/Owbw/3mvF0efs61ayErxxo3N
         BU0w==
X-Google-Smtp-Source: APXvYqyHZp5mS+lTbi7oHxO2epL8R4NOTNAiFsqbAXeHsoAardI7S/ru4DZLvBbeyI1nBk/ngZYE4g==
X-Received: by 2002:a17:90a:30e4:: with SMTP id h91mr69268220pjb.37.1563724698104;
        Sun, 21 Jul 2019 08:58:18 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id v27sm48568911pgn.76.2019.07.21.08.58.16
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 21 Jul 2019 08:58:17 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: arnd@arndb.de,
	sivanich@sgi.com,
	gregkh@linuxfoundation.org
Cc: ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH 0/3] sgi-gru: get_user_page changes 
Date: Sun, 21 Jul 2019 21:28:02 +0530
Message-Id: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch series incorporates a few changes in the get_user_page usage 
of sgi-gru.

The main change is the first patch, which is a trivial one line change to 
convert put_page to put_user_page to enable tracking of get_user_pages.

The second patch removes an uneccessary ifdef of CONFIG_HUGETLB.

The third patch adds __get_user_pages_fast in atomic_pte_lookup to retrive
a physical user page in an atomic context instead of manually walking up
the page tables like the current code does. This patch should be subject to 
more review from the gup people.

drivers/misc/sgi-gru/* builds after this patch series. But I do not have the 
hardware to verify these changes. 

The first patch implements gup tracking in the current code. This is to be tested
as to check whether gup tracking works properly. Currently, in the upstream kernels
put_user_page simply calls put_page. But that is to change in the future. 
Any suggestions as to how to test this code?

The implementation of gup tracking is in:
https://github.com/johnhubbard/linux/tree/gup_dma_core

We could test it by applying the first patch to the above tree and test it.

More details are in the individual changelogs.

Bharath Vedartham (3):
  sgi-gru: Convert put_page() to get_user_page*()
  sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
  sgi-gru: Use __get_user_pages_fast in atomic_pte_lookup

 drivers/misc/sgi-gru/grufault.c | 50 +++++++----------------------------------
 1 file changed, 8 insertions(+), 42 deletions(-)

-- 
2.7.4

