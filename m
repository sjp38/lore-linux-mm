Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75543C06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 178802146F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:20:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=plexistor-com.20150623.gappssmtp.com header.i=@plexistor-com.20150623.gappssmtp.com header.b="1wUdmopY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 178802146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=plexistor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84E446B0003; Mon,  1 Jul 2019 13:20:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FF2C8E0003; Mon,  1 Jul 2019 13:20:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 715028E0002; Mon,  1 Jul 2019 13:20:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f79.google.com (mail-wm1-f79.google.com [209.85.128.79])
	by kanga.kvack.org (Postfix) with ESMTP id 28BD86B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 13:20:59 -0400 (EDT)
Received: by mail-wm1-f79.google.com with SMTP id v125so100243wme.5
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 10:20:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RMtO9zTMwULPwpFiTkeooNGzR9zKo/UB7YgL+t4fgzA=;
        b=Qlgo2+TWCRckaiwbbp8HfjIiGNJAtjbH+36qsp7m5ZWq8kSZeaDOkjIDyriQQBpxKh
         jWAIOO+0YBcM9V+Js6pO4+ULUMsq6ZzhmZYLDe8+vpjoA5DioLXdFQZNdpLa4LeycDfS
         EFEmou4+a+dUV4AGp2RbAvQUE6KipYaQ2cDsj4Rot7iG1KpZFgUeTGrtxf7PzWTchBAL
         8deULoN5xVGRn1tQIe+n2Rb5fIwAGqqDAUc1V23TSNKO9HKJQQ7GuE6mIFyMFnXhzqIn
         InIJd+VXzQLuyq8O2sDuk/T4Sn+qsJLue1Dvdv2uh/szTLk8ymNw+opl5NPLGR8UJpip
         1EOw==
X-Gm-Message-State: APjAAAVga2HvL98EIsAeGk77iFq2oYYREDO6S2hlYTe6ZBidg45m+XyR
	6fnqizUqSmmyCS2cs9CswFKvZ/F8KUUfm1aiHkEB9wW2kdfiE4YWgwuhYSXJhxEdalvjkbirycw
	460NyFnw4XPG5KX8/zVQx/8dLM3Lwq0sXbqny6sk5cU5XJiHuYZtbUYWyZUw033z7IQ==
X-Received: by 2002:a5d:4090:: with SMTP id o16mr744115wrp.292.1562001658429;
        Mon, 01 Jul 2019 10:20:58 -0700 (PDT)
X-Received: by 2002:a5d:4090:: with SMTP id o16mr744069wrp.292.1562001657500;
        Mon, 01 Jul 2019 10:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562001657; cv=none;
        d=google.com; s=arc-20160816;
        b=I54z2Ix/2Dr6XSzjy5CwE0dVZo5M08bZvRDwjxGB5KSuvKVazj3QQe8MRDOqbSQRy3
         5yK3LTGvUZK75G2T0fMfSQ8lJnHdVLn6I/7pcLISAFyJUX9AadplEcF4HYTZzLyOayQS
         tQwr24ll/o+LCugPXKh4qUOs3RiO8Ezjd7B8iRlLopruG+Yyo+sBB8QslfHUPCVuFSXD
         ZXrz44WWJnhN0bV3YBuvyv+XArK+CV/dlZkeTI8+E9fwM92MQHmiA9IXlJglRPFobZbu
         4zGl1l8segC5oQNBFPhMVAdFcCEVjuRmYMReV1R1ZA2D4hJs9oJEEIAKUoW+2o526VnV
         VvNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=RMtO9zTMwULPwpFiTkeooNGzR9zKo/UB7YgL+t4fgzA=;
        b=Jf43OLrEYweZ2XsvTHn6jcMGbgjRZBdFi3YMWSs4L98NUOGWdD0VO+fTmyoIMKUXkf
         TcG3/7jYAbkwlyLVi3QElyj0V7NHyTzdOAMLFDsg9KJTFWZ1jYrehb9SG++XFfGvOU96
         Mo+bPAU/UXcxvOGnxjGPb41TFZNj/HKMXSe0Xao9tXAyj3+WXpxhtCkJ59DouNhtviNF
         TzrU+PVWuEHVW5agc1XZ5i7WDKImpjPHLbteohleD2Lf/WgejcuUyZ7+lQSqGwv1Mj+n
         bSMI4SwFxXZ0iQ1Jnb3uRaOSKGcQCPdXvEcWcEUMjwVQOQFEiiXOR5pizPHC5MBzUJhV
         y0+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=1wUdmopY;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor160365wma.3.2019.07.01.10.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 10:20:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=1wUdmopY;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=plexistor-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=RMtO9zTMwULPwpFiTkeooNGzR9zKo/UB7YgL+t4fgzA=;
        b=1wUdmopYsOTGEBPctCCQBJNp/Weny3U0OdMAgIX7XMpDLNjX7yi2BQKVOeIOZfgf1b
         I2dQPvs1YcMd4MKfGasxoR1vUF57n1uWvGfOwCBn+dFFXqdtzk7+nDTMfgxaIC1cMqAd
         CyXSD5wWJrsSE7f66iNNQpS8suPAgj9SNlBFoRgvaYPLl2O9hulyvjxbO8s6Guhj4y1S
         Nf6nnLqhsslQUJQ8lQjHCR002MedRLPvKNFje/NywIlwBVxr1dbYLS/Ag6d45MoLEFLA
         TB43Jl9ECXn6C3ClznsgSlBckfDR8AQM1se/327D0FreZlmY9S9DkHpcHai8gVFUiAbk
         jAnQ==
X-Google-Smtp-Source: APXvYqyJIZEjZ99B+K6R50DPm7lq0IHr/E/1lfJMHdrHDPCDWuYMn1JV6lQAB5xdWdZjMaq23hnwbA==
X-Received: by 2002:a1c:f009:: with SMTP id a9mr234245wmb.32.1562001657000;
        Mon, 01 Jul 2019 10:20:57 -0700 (PDT)
Received: from [10.68.217.182] ([217.70.211.18])
        by smtp.googlemail.com with ESMTPSA id q193sm269299wme.8.2019.07.01.10.20.53
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 10:20:56 -0700 (PDT)
Subject: Re: [PATCH v6 0/4] vfs: make immutable files actually immutable
To: "Darrick J. Wong" <darrick.wong@oracle.com>, matthew.garrett@nebula.com,
 yuchao0@huawei.com, tytso@mit.edu, ard.biesheuvel@linaro.org,
 josef@toxicpanda.com, hch@infradead.org, clm@fb.com,
 adilger.kernel@dilger.ca, viro@zeniv.linux.org.uk, jack@suse.com,
 dsterba@suse.com, jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
 devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
 linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
 linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
 linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-btrfs@vger.kernel.org
References: <156174687561.1557469.7505651950825460767.stgit@magnolia>
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <72f01c73-a1eb-efde-58fa-7667221255c7@plexistor.com>
Date: Mon, 1 Jul 2019 20:20:51 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <156174687561.1557469.7505651950825460767.stgit@magnolia>
Content-Type: text/plain; charset=utf-8
Content-Language: en-MW
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/06/2019 21:34, Darrick J. Wong wrote:
> Hi all,
> 
> The chattr(1) manpage has this to say about the immutable bit that
> system administrators can set on files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> Given the clause about how the file 'cannot be modified', it is
> surprising that programs holding writable file descriptors can continue
> to write to and truncate files after the immutable flag has been set,
> but they cannot call other things such as utimes, fallocate, unlink,
> link, setxattr, or reflink.
> 
> Since the immutable flag is only settable by administrators, resolve
> this inconsistent behavior in favor of the documented behavior -- once
> the flag is set, the file cannot be modified, period.  We presume that
> administrators must be trusted to know what they're doing, and that
> cutting off programs with writable fds will probably break them.
> 

This effort sounds very logical to me and sound. But are we allowed to
do it? IE: Is it not breaking ABI. I do agree previous ABI was evil but
are we allowed to break it?

I would not mind breaking it if %99.99 of the time the immutable bit
was actually set manually by a human administrator. But what if there
are automated systems that set it relying on the current behaviour?

For example I have a very distant and vague recollection of a massive
camera capture system, that was DMAing directly to file (splice). And setting
the immutable bit right away on start. Then once the capture is done
(capture file recycled) the file becomes immutable. Such program is now
broken. Who's fault is it?

I'm totally not sure and maybe you are right. But have you made a
survey of the majority of immutable uses, and are positive that
the guys are not broken after this change?

For me this is kind of scary. Yes I am known to be a SW coward ;-)

Thanks
Boaz

