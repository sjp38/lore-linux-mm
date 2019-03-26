Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB882C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:43:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7034520857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:43:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7034520857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F2976B0005; Tue, 26 Mar 2019 05:43:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A39A6B0006; Tue, 26 Mar 2019 05:43:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED3A26B0007; Tue, 26 Mar 2019 05:43:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C90A36B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:43:52 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f89so13012258qtb.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:43:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QCizQ97iFHFupifD4fwTmILxT9fDseU02cXbQ3W44nM=;
        b=RR6+gKtRaw+wPX4V5xIgrL2IReuFW31GJN36Rsoxx4nokSQqTH3XxzuL0MvFO0rOCg
         kYYpmBxQHKfAttV6mC8qlBN/KEGxF6TCfcT4/T/UWx4ZgNTCj5VZM4sjwfF7jMRaiFeh
         TIuTFp4lqk7VOGZgGJB+JY33y4i+4GtdQhQ9JF6NHfXaREb7co8V1b07UevE1L7kePew
         LZ497xK0H6Xt60cSYLuI7+51On/jjl6sMHoG4A6Gsju89Pf1PwMr1eRkqjKwCsA1SygJ
         HZAiRljBDeDUZCjkH8ZTT6Ce3Fr6kab6tBPlNAGaNcbh4fUt6MnV8Z+8ND8FUTFCN77b
         4w0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWFFunl0Vk9pL/ZEmZ75QfQE8K2XGAg+6R/z+JPQyAoyushUv7g
	Uvv9Tzu/crbrSaEx7r8dwjQgs0eX8bw36XBFLAhncLD1fQBU77UrrnnX1DVUsOVNzhcUJz8rpFA
	ta/TRbPCudp77h5bbz97behckfWFXgYMztk7T3qaZ1Xaa3jk987b12SGS25Qw0fbMMw==
X-Received: by 2002:a05:620a:118f:: with SMTP id b15mr16002379qkk.162.1553593432595;
        Tue, 26 Mar 2019 02:43:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFXwvgewymenac9SqkiQbcvrLxH6ziwC6iMzGFcb91JPtz4i6A0zcWA3pYzTVOHrAtJr2v
X-Received: by 2002:a05:620a:118f:: with SMTP id b15mr16002351qkk.162.1553593432038;
        Tue, 26 Mar 2019 02:43:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553593432; cv=none;
        d=google.com; s=arc-20160816;
        b=c/j/hHze8K4zuZQ/G2fJZhiDCBo9AUfFrXZIU8J5apHLCqpcu7oJCXqH4lndQt8cib
         j2IWhyVbfkE4sfL0oQjrZsbd8PVFAdzfZBvEFOTQytCjb/3aUkd8ZDldwTEnjjbxscn4
         rk1q2Cj9i+8vof02/4mGw1F3Hh6nMRCMSMvCEH2bUYkCj1AssOwglw0/qGIhmsdnKhE8
         O6KxZ5i20vr5xNjnFzHHYcXT6QN8PbJF1muJ4nWwuubH+hgfbaRuRuoSw2hv6fFmxUbm
         stdDjSoeK/Gp35UAUcMrSYsxC//8Ef38Kco8bfhEUG4vgG9/W08cvKKUyfXGSQWhnh1u
         T4lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QCizQ97iFHFupifD4fwTmILxT9fDseU02cXbQ3W44nM=;
        b=slWjz7/TlrTL8PiTEA4DTXZhyB32Ex/NuaC1HejNHoXrpLI3K83zXR/P185CsmJazF
         XwXHs3oSWPTIvfQ1WAMn99MAnj+I3kawsy2fJFZsAuLbJYWMZPuwEhGXd4cwen8ZkCxa
         jw2+eN7ugZppTIxhnkW2jG5e/1PxhoDv7tuWL3A17wCs/paprk2vdXJk3+GXedUn4b/M
         QPcpRduGwAgVNoNdNsfIozlEG3pD6/lHIQlIPGet6ldfWp/OMd0at54JTI5VBpKhKm3r
         LMrmnYaGLn0ygRfV4PT80I+goGlJfMsoOnTqK3v67xQ8RUlXSKqUrLUPlBt8pXcDO4PE
         jnUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v91si3089066qte.315.2019.03.26.02.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:43:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 38C7B3084026;
	Tue, 26 Mar 2019 09:43:51 +0000 (UTC)
Received: from localhost (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 886241712F;
	Tue, 26 Mar 2019 09:43:50 +0000 (UTC)
Date: Tue, 26 Mar 2019 17:43:48 +0800
From: Baoquan He <bhe@redhat.com>
To: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, rppt@linux.ibm.com,
	osalvador@suse.de, willy@infradead.org,
	william.kucharski@oracle.com
Subject: Re: [PATCH v2 1/4] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190326094348.GT3659@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-2-bhe@redhat.com>
 <20190326092324.GJ28406@dhcp22.suse.cz>
 <20190326093057.GS3659@MiWiFi-R3L-srv>
 <20190326093642.GD4234@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326093642.GD4234@localhost.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 26 Mar 2019 09:43:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/26/19 at 05:36pm, Chao Fan wrote:
> On Tue, Mar 26, 2019 at 05:30:57PM +0800, Baoquan He wrote:
> >On 03/26/19 at 10:23am, Michal Hocko wrote:
> >> On Tue 26-03-19 17:02:24, Baoquan He wrote:
> >> > The code comment above sparse_add_one_section() is obsolete and
> >> > incorrect, clean it up and write new one.
> >> > 
> >> > Signed-off-by: Baoquan He <bhe@redhat.com>
> >> 
> >> Please note that you need /** to start a kernel doc. Other than that.
> >
> >I didn't find a template in coding-style.rst, and saw someone is using
> >/*, others use /**. I will use '/**' instead. Thanks for telling.
> 
> How to format kernel-doc comments
> ---------------------------------
> 
> The opening comment mark ``/**`` is used for kernel-doc comments. The
> ``kernel-doc`` tool will extract comments marked this way. The rest of
> the comment is formatted like a normal multi-line comment with a column
> of asterisks on the left side, closing with ``*/`` on a line by itself.
> 
> See Documentation/doc-guide/kernel-doc.rst for more details.
> Hope that can help you.

Great, there's a specific kernel-doc file. Thanks, I will update and
repost this one with '/**'.

