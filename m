Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A01C0C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F3E5230F2
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:24:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H9A7VyZ+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F3E5230F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3FDB6B0008; Tue, 20 Aug 2019 12:24:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D30C6B0270; Tue, 20 Aug 2019 12:24:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B69E6B0272; Tue, 20 Aug 2019 12:24:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id 645FC6B0008
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:24:44 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1359575A4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:24:44 +0000 (UTC)
X-FDA: 75843329688.24.shelf04_29421acad651e
X-HE-Tag: shelf04_29421acad651e
X-Filterd-Recvd-Size: 5741
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:24:43 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id x15so3525416pgg.8
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:24:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rtMtxwDFxfWyDwI2VJqXw7UwN79Bf7nonGtI8wZ/AV8=;
        b=H9A7VyZ+AkTGb6fh3lCfYFGef3H3WPjC2RH9jX+XiptcELpZO/IVJTMVyT/Sf+dan4
         weppXZXhDW1iXlZiUi9HyLv0TBydmXbI3zPIZVbjCAoURMxwCDt8a2NtMYgypF1CQVn2
         GlCPw+7OQLfLpiS8IbIi31vp55DWdGaBbCrQVXg/73mzxpSao9JWB1WzD/IhP3260bX5
         5mpugFVHPCO5zvNjd7SrMXBvGliNdJOHt8A2c6JGgk4vMq6RFMvShQZ7QfFAHUxKGKo8
         ER9tanSNhKNj9azM984ZKZlcnPL8HHkvpGy8wxMfgD5b3vJGcLrzzls2YVUElDPhKvB9
         zONg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=rtMtxwDFxfWyDwI2VJqXw7UwN79Bf7nonGtI8wZ/AV8=;
        b=YYP1nLR64rS9jg5bCtA9YgbdVVRj4mmyqT8b5BEHnWkwC7S1eLuD/kkv//rpx4h1KQ
         G5fjtCRA8vw3U+FfhHiMmE6aFHRJGhCT20khHpxusy7N0Wf9+/3VoOayGb8BFPTZHbmz
         lcyDhgA+o4zCWKHA8q/ty9CXqnnLhV0ZGdX7jVGFre0ha3BpDhK66kRnRlWN63l54ZJV
         s4LPQ6r31Wv/1dLIBjLzQA6oS+Xn67GwkkMDBTaF+sm1yJw+QH2Ofj7RGlPfgmtgJfqo
         zrP1d5yQh1mKcLlU9DZIWVrWR59NtqA1JMd7Ydw3Mm9HQb8+mjYIkxhlOTScrH52jJ54
         0OKQ==
X-Gm-Message-State: APjAAAV/smBHT6tEKTfaYGKYZ2T1qoMeR+FxTTcg8pcFUUtSC0T4EV0X
	GZYmgvuLswHkh1qjuSYtL5w=
X-Google-Smtp-Source: APXvYqye5R5yNp/QaiKoJoPnfGJSyMAFG3pnY1LWDO29qhAN2U+W/GyrfTDuBR3N7CFkLUvF8H4MWQ==
X-Received: by 2002:a63:9e43:: with SMTP id r3mr25940504pgo.148.1566318282238;
        Tue, 20 Aug 2019 09:24:42 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.36])
        by smtp.gmail.com with ESMTPSA id 203sm31373737pfz.107.2019.08.20.09.24.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Aug 2019 09:24:41 -0700 (PDT)
Date: Tue, 20 Aug 2019 21:54:32 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dimitri Sivanich <sivanich@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>, jglisse@redhat.com,
	ira.weiny@intel.com, gregkh@linuxfoundation.org, arnd@arndb.de,
	william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [Linux-kernel-mentees][PATCH v6 1/2] sgi-gru: Convert put_page()
 to put_user_page*()
Message-ID: <20190820162432.GB5153@bharath12345-Inspiron-5559>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-2-git-send-email-linux.bhar@gmail.com>
 <20190819125611.GA5808@hpe.com>
 <20190819190647.GA6261@bharath12345-Inspiron-5559>
 <0c2ad29b-934c-ec30-66c3-b153baf1fba5@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c2ad29b-934c-ec30-66c3-b153baf1fba5@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 12:30:18PM -0700, John Hubbard wrote:
> On 8/19/19 12:06 PM, Bharath Vedartham wrote:
> >On Mon, Aug 19, 2019 at 07:56:11AM -0500, Dimitri Sivanich wrote:
> >>Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>
> >Thanks!
> >
> >John, would you like to take this patch into your miscellaneous
> >conversions patch set?
> >
> 
> (+Andrew and Michal, so they know where all this is going.)
> 
> Sure, although that conversion series [1] is on a brief hold, because
> there are additional conversions desired, and the API is still under
> discussion. Also, reading between the lines of Michal's response [2]
> about it, I think people would prefer that the next revision include
> the following, for each conversion site:
> 
> Conversion of gup/put_page sites:
> 
> Before:
> 
> 	get_user_pages(...);
> 	...
> 	for each page:
> 		put_page();
> 
> After:
> 	
> 	gup_flags |= FOLL_PIN; (maybe FOLL_LONGTERM in some cases)
> 	vaddr_pin_user_pages(...gup_flags...)
> 	...
> 	vaddr_unpin_user_pages(); /* which invokes put_user_page() */
> 
> Fortunately, it's not harmful for the simpler conversion from put_page()
> to put_user_page() to happen first, and in fact those have usually led
> to simplifications, paving the way to make it easier to call
> vaddr_unpin_user_pages(), once it's ready. (And showing exactly what
> to convert, too.)
> 
> So for now, I'm going to just build on top of Ira's tree, and once the
> vaddr*() API settles down, I'll send out an updated series that attempts
> to include the reviews and ACKs so far (I'll have to review them, but
> make a note that review or ACK was done for part of the conversion),
> and adds the additional gup(FOLL_PIN), and uses vaddr*() wrappers instead of
> gup/pup.
> 
> [1] https://lore.kernel.org/r/20190807013340.9706-1-jhubbard@nvidia.com
> 
> [2] https://lore.kernel.org/r/20190809175210.GR18351@dhcp22.suse.cz
> 
Cc' lkml(I missed out the 'l' in this series). 

sounds good. It makes sense to keep the entire gup in the kernel rather
than to expose it outside. 

I ll make sure to checkout the emails on vaddr*() API and pace my work
on it accordingly.

Thank you
Bharath
> thanks,
> -- 
> John Hubbard
> NVIDIA

