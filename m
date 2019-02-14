Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EFAEC10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57B9A2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:08:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57B9A2229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA8348E0002; Thu, 14 Feb 2019 09:08:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E588D8E0001; Thu, 14 Feb 2019 09:08:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6EDF8E0002; Thu, 14 Feb 2019 09:08:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 810E28E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:08:25 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d62so2569036edd.19
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:08:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tQcl4MrbtmQEjmQQjXwkodsx+D7+hCY612W563z9hoQ=;
        b=dPinMkYi/h0EWY8DoS7FEY9CVkwQ7UZfH9m3g3rKv9gLSumnIP/+arjMLG9bh1/U09
         aPTKAW9jXpqQ4EST7meAdx4DY3na6a1E4COoRzcHsEoOKWaxx6D5US8zi3nmZDNHvnCQ
         9koTNb7Kcqi2UrujbHr4MMmpo6tBMzaaa64cpSD+GKLH0Dmqg7Xpsiq8LBnVAw7LRfCq
         EyJpBjf/J9gWj+EI7DTUSQK0iJnhm4gkb1EDkZYcUDsVNU7N7D7dqqcjNTGZ7ko5mgzu
         T54Pg8ffBh9XpWChcq4kkYwAK5QLtfI1XbD+LK2ehcGtNd7uwoObaLTp2+LVekLtd4B+
         ayog==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub6j3t8CEb2CluHx999gD+NgWEAh8C2bJnn7fvPGZceLZ7EDdoL
	CeET5TJ4XIQX62+ajUN75OCXI9bNANFUCHswqJwxGayRJ7td0j+wiLfVTz0e9RQ+biPpVt5NTPN
	epI8RTU6H0wvceDu5uvgpFIYWCevOun5ol1jhlbGvaWQxXdCeCfZ4J2l3o0fJbzI=
X-Received: by 2002:a50:bdc6:: with SMTP id z6mr3320604edh.64.1550153305068;
        Thu, 14 Feb 2019 06:08:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYw1TqeoRCx71foqBkj9ZwZGkgpVsHgDP3yffZui741nUFY83xp+SShoMv35V7aMru16io2
X-Received: by 2002:a50:bdc6:: with SMTP id z6mr3320519edh.64.1550153303820;
        Thu, 14 Feb 2019 06:08:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550153303; cv=none;
        d=google.com; s=arc-20160816;
        b=fjpjj/S/BW32w4b070rg7hHmiDtE423jZHW0lf7QM1YsbrM4U+EyLVsLhjDISAIKzN
         c9Bgq7ovUNpVgu+ffxVCJ35WxnAwQCNSSo+LlJdNMT4Iljl0/G3ZMv8box1hQorGkMnu
         v3qFJehZHhQu7Mt5MhmYyKY2Z/q6/58RJ3lodysZsbQAfSWvCseUVGp2Wp8BITcgMYyM
         rmO/xjXX7YJQdA6kz71ef7y7y6aD2rCRzQr0KU7uXRSCjTMwWva2UsK69sXR2WEipYnL
         jQK/G7p82mZNve3gwOVH4y7NcSzm5z1E3WiCOGqsCCZcU1W1BuE8Z7p7OIlwpH9PW/eS
         nFeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tQcl4MrbtmQEjmQQjXwkodsx+D7+hCY612W563z9hoQ=;
        b=oL8YVQfvtPcO+qKyMnNPtDTAq7LBTS1K7dLGyXGE8GmvK9k88Ptp9ixxYHZcArACF1
         rfI3zmY0nwNmhjp+qGcakKV1IRQ2lSxumbAeLZdiUId8ctE11VFrW+E8BzgpYsOjwNZj
         B+gOEZXgIKxxQgBgBnx9/2ANd/u2n5BVSPt2VkjdFhOwJdAPJPk2iGESH8MoV2COAj4+
         QgHVj/qbmyhoYp++1C7dItc+Mn0Bu42+RDBVcA40x9mMEnJLPWx6K6FyPCnX0WQ3+/kx
         150l08maY4qYvzsWUhteffMteS5c2rKtCH3BbaFVMqd+QDdX74/X2aU6ML+qpv9SWt3D
         6J9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si1056479ejx.292.2019.02.14.06.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 06:08:23 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5329BACE3;
	Thu, 14 Feb 2019 14:08:23 +0000 (UTC)
Date: Thu, 14 Feb 2019 15:08:22 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	"linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
	IDE/ATA development list <linux-ide@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	"linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
	bpf@vger.kernel.org,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ast@kernel.org
Subject: Re: [Lsf-pc] LSF/MM 2019: Call for Proposals (UPDATED!)
Message-ID: <20190214140822.GA7251@dhcp22.suse.cz>
References: <4f5a15c1-4f9e-acae-5094-2f38c8eebd96@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4f5a15c1-4f9e-acae-5094-2f38c8eebd96@kernel.dk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 07-02-19 08:35:06, Jens Axboe wrote:
[...]
> 2) Requests to attend the summit for those that are not proposing a
> topic should be sent to:
> 
> 	lsf-pc@lists.linux-foundation.org
> 
> Please summarize what expertise you will bring to the meeting, and
> what you would like to discuss. Please also tag your email with
> [LSF/MM ATTEND] and send it as a new thread so there is less chance of
> it getting lost.

Just a reminder. Please do not forget to send the ATTEND request and
make it clear which track you would like to participate in the most.
It is quite common that people only send topic proposals without and
expclicit ATTEND request or they do not mention the track.

Thanks!
-- 
Michal Hocko
SUSE Labs

