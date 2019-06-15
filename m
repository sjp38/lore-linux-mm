Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70B2AC31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 22:38:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B9B121841
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 22:38:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="x7agobaf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B9B121841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 749566B0003; Sat, 15 Jun 2019 18:38:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F9846B0005; Sat, 15 Jun 2019 18:38:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60FD28E0001; Sat, 15 Jun 2019 18:38:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 396A56B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 18:38:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j36so4697247pgb.20
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 15:38:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BUyUhZ4q1if9QMjFUVdtd/uzawhIDLu3vUCDGW+hGR8=;
        b=I9TQqJ44/FCQU+1fp1ThYLDNQ+uUJ+UjSTAQeYUm9CYfTKPjkTB8l/J4/1ZvTNfHg8
         U5FtpLTRUwScPfL3hAPpKjLtEbIFJDRRdMuWNo9EdDn8ZZy3ZaCgPlXVt5/2hGlwxjso
         3VTOKMaNkIcmjDTFD890PAI/kiUD4zyL54EHdnzz7/wNWX1+w/212NHGolhhmVMUwocw
         yrtJP0MGWRf9WPZUQtAhnPCyqYQ7cMXF7/Sg3zv3CsYQObIhui0m8BAbqO1QzPVwFfFl
         vFbAvNBLSZkELtATfFMD1h3xM7zWzNtC0GsslvtYg1lAOfsNQQP6MQCP5vRySApHeGD4
         ARMw==
X-Gm-Message-State: APjAAAVDEMz//w18W0Z8PEssD7R/eT27rncYqG5Za2tVMxhuN/Iy5mW0
	87cw/rZGwBHzkCBqNQ7hXTjMU6KBGDQB/6y129VM1XEqomCj8TMI35DAM+BFGCDzQhDZKW+sCEm
	hoHFiRznijQpJy9TCeU8S3c/zWU+kEtdExvlGQGXwDKNB0yyqLMa3DwGMNwmNjuVT4Q==
X-Received: by 2002:a17:902:a607:: with SMTP id u7mr95163943plq.43.1560638327878;
        Sat, 15 Jun 2019 15:38:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmbDVYSKdODb5YBHTFCMfN/eC2SvjNf2SgDf8OQDP8dWeP2wSsCXQJ2tHlcdppzI+r/GmP
X-Received: by 2002:a17:902:a607:: with SMTP id u7mr95163906plq.43.1560638327175;
        Sat, 15 Jun 2019 15:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560638327; cv=none;
        d=google.com; s=arc-20160816;
        b=R6kIG8RhWIvZhQMkjcdksZcEJbh2SMW2Cj7wgKI8+/61HZUVJwCpeHfzyLfRUQR4ua
         S80r8xnyWsbp7SvmEPq0XgthBFauXD4c1WEDVyKC/fIctnY43X65ibRqF3gHKEr/u5BV
         aDi8BPmzRRUzYKhqCgscNDTbKuOLrG//0bY5R/gr+sQO0qQU8/Nbpvo4fRBt41mv2K73
         iQgLF/sB70lLOZ9zKitKHrydBiK8D4CaDCXepvsmATVa2Dra5vcJkEHYmfuqac8SiJDS
         mEdcVt+95QlNWIR1LpROifkyO5+kMux+DlTIw32wNHM5IPTOpJgZM4tDV1NnwWgvduSn
         N48g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BUyUhZ4q1if9QMjFUVdtd/uzawhIDLu3vUCDGW+hGR8=;
        b=NPKchO78n9TcDCiUsgmUc5qr0DqXVis6ryAhsZOReVuTmTvZ4zkZM3UlcEfQOyy81D
         jfd5zZJPS8Jg90gQHxQKUNiQI36FZMa+zFhv3imfDxPaf9go/NDzWcBQ7hZsjPTh8DzE
         uDTsHNQWsPDctOxtuMJmg4EqbtKBSkhJo6p/gYpl+ZQnwStqV+xsxPSTPwP8wu2XQNE8
         W693pThT7kHfuc20rTxnynJa6qNEV+vhmaY/QDb0M3XFOwauUlKGLInrdbb2G48YHQXC
         oO9UcwmspQ3Zk9pUGpIHOsgFvtsloBPbSfc/zgVmP1HdP6lHg7iX/yBkeYA/c3A863hg
         b+Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=x7agobaf;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j100si5883756pje.52.2019.06.15.15.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 15:38:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=x7agobaf;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [107.242.116.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 31F752073F;
	Sat, 15 Jun 2019 22:38:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560638326;
	bh=BUyUhZ4q1if9QMjFUVdtd/uzawhIDLu3vUCDGW+hGR8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=x7agobaf94z2juYUTQD4S2nA+EtWg6Pc8lQu6q/c9fQy/7yRX5jmOYNBWMfW5UNZM
	 rpHBRCSMaJ/h9kVxMrAXh8hiRNb5AkSo9s744F0+vPXbnSX85m37VALB1DLQP/7Ufb
	 rHcegzPEulk+26A+4T23psdzCCOiz3TRNLbnzF6M=
Date: Sat, 15 Jun 2019 18:38:43 -0400
From: Sasha Levin <sashal@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
Message-ID: <20190615223843.GT1513@sasha-vm>
References: <20181203200850.6460-3-mike.kravetz@oracle.com>
 <20190614215632.BF5F721473@mail.kernel.org>
 <f8cea651-8052-4109-ea9b-dee3fbfc81d1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <f8cea651-8052-4109-ea9b-dee3fbfc81d1@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 04:33:53PM -0700, Mike Kravetz wrote:
>On 6/14/19 2:56 PM, Sasha Levin wrote:
>> Hi,
>>
>> [This is an automated email]
>>
>> This commit has been processed because it contains a "Fixes:" tag,
>> fixing commit: ebed4bfc8da8 [PATCH] hugetlb: fix absurd HugePages_Rsvd.
><snip>
>>
>> How should we proceed with this patch?
>>
>
>I hope you do nothing with this as the patch is not upstream.

We do not, it's just a way to get more responses before people moved on
to dealing with other work.

--
Thanks,
Sasha

