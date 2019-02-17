Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17319C4360F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 13:10:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B364F222E0
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 13:10:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B364F222E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 253C08E0002; Sun, 17 Feb 2019 08:10:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D9D28E0001; Sun, 17 Feb 2019 08:10:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A18D8E0002; Sun, 17 Feb 2019 08:10:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D011E8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 08:10:51 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q33so13999221qte.23
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 05:10:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=idHFXYR6S/qYo2651OVv7ru+dKEcKzkTVcr1oIDeUb0=;
        b=p6JKlrE4L8A5r1UyOaaMmxVHsYZJN5w6PCjFWgBrYnB2eysvCq02t1wNJfMddthzU1
         d5sTfTpeKZJN/VvVjWP/xWAVC6dzWlt0mUGaxTce0JNF0MBMud1XWxT/acDoH9y0VHNx
         u6z/eHr+rhzyWjcAtBzJ+1dBgxc2kii5q8DsL4s6T5hZDcSlW4RIXbWnngxgT3LUxa3F
         s4rO2WQzzjsPoVGqXaeXzRuMp0jWtfXcL1T9EXIU8KjP7iox7GUs4IBcS4dVTJp5uv4r
         SU2+84GgVX7wPJsc6tJwRM7aMWpgn2U4qsLRIgJZ8peKuyAkH724qmXcC2hYy2NrS8vf
         zTRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubgzrzsr+YilkiTNLiEBHKu5sjwRReg+OKIYS12HsJ0tdTw7mx9
	weXDgNID+Ta3eD8zBAFOziq3ZQ4Ctdgn8hFDqAR4cwdRpGjphKJoZ3jhemnzEUaOPjhRUuerQ4U
	QhtqKl15f8kf5HSKiFPHIThHcAMPaKHO1MgqdqjQZVAyRRdneCm7e/bA/bmYLj5lOKQ==
X-Received: by 2002:a0c:941b:: with SMTP id h27mr13995686qvh.8.1550409051511;
        Sun, 17 Feb 2019 05:10:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia6dC0ZXNWHhFTL+cHgkCeedPe9/B8OeRzD0KNTWvwgcUeD8Ldw3K2wAUT1/O7pNzpqQ7CP
X-Received: by 2002:a0c:941b:: with SMTP id h27mr13995663qvh.8.1550409050891;
        Sun, 17 Feb 2019 05:10:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550409050; cv=none;
        d=google.com; s=arc-20160816;
        b=yR65vwN1wLDxt630R/W/hHpSwMpzptbyaKzHtDdlBFKkXxlrM/ZsMVPQGPNv3Rc1Qz
         mxlAGGdvGnuOlKQ5uA/lUyHzfSYIIsIXYMOFpzg60KDLuc24+IxwSXvgKYcAAdtZ9YbF
         7VT9dcBfaRQUj/tPDxl2Eeo1Hj/uiajhO6mE6LqC+7GSYgS7Qgr60H9z3hN6aAWSECxO
         aiinD00SkmcTXlhSCCkVUPpjjeRU48sqiag5pew1UD2sDV+rIikRWQUqyNpnP164NC8g
         c2z+la77sZA/C33tKQLrnR8yqvyor1hjglEuLo6EvmFn6tKFXhkONGqTn1Yxgznq0W5G
         M0ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=idHFXYR6S/qYo2651OVv7ru+dKEcKzkTVcr1oIDeUb0=;
        b=CBnukiWW7xOstF5mz8vLSzm9iR4anJLP0z+mFSY/pFlL7Rcy2UpL2aeeDHnqJK54Hj
         oGocWgJpm7tQg+ZZxCWvs9EL6Mt/6PEx8iorgB5HcpkTqDB5HorXto1lr9UD+WDYUeZU
         1GcsY2I/wgc+Tv4xum/MnrkoL3HiQ7Q7X1FXqH2dc7c95mZN+DrACP80JJyBeSrIQ7QD
         s635qwbMd0+FlixBYEbiv81Jw51PiMeGWVYDTysI/a/DYLjtQfyNNyfThoVYKT96mOe2
         t40k1AEwfy81o/n3qsOfAM5dKTeKJsnCh/UzdJTZ1K4rjrEVhQn73nHxvQAC+DgwadyP
         wkRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a10si2872950qvj.12.2019.02.17.05.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 05:10:50 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6FEABC051685;
	Sun, 17 Feb 2019 13:10:49 +0000 (UTC)
Received: from ming.t460p (ovpn-8-16.pek2.redhat.com [10.72.8.16])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 931F8101E846;
	Sun, 17 Feb 2019 13:10:28 +0000 (UTC)
Date: Sun, 17 Feb 2019 21:10:23 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>,
	Sagi Grimberg <sagi@grimberg.me>,
	Dave Chinner <dchinner@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org,
	David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>,
	linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>,
	Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com
Subject: Re: [PATCH V15 00/18] block: support multi-page bvec
Message-ID: <20190217131022.GA7296@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <20190215145126.GA16717@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215145126.GA16717@lst.de>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Sun, 17 Feb 2019 13:10:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 03:51:26PM +0100, Christoph Hellwig wrote:
> I still don't understand why mp_bvec_last_segment isn't simply
> called bvec_last_segment as there is no conflict.  But I don't
> want to hold this series up on that as there only are two users
> left and we can always just fix it up later.

mp_bvec_last_segment() is one bvec helper, so better to keep its
name consistent with other bvec helpers.

Thanks,
Ming

