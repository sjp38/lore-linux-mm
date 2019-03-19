Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1594BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:52:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA8172175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="lvB7QQql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA8172175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618B76B0003; Tue, 19 Mar 2019 10:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C97F6B0006; Tue, 19 Mar 2019 10:52:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4919B6B0007; Tue, 19 Mar 2019 10:52:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 070CD6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:52:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so23062736pfj.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:52:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zB1hQjC0mgnVNeuNNiIBwxKkFopOSlcbEb5hoUvPPwk=;
        b=ZhUgIkTmI8ZzSjnyu0jBJtuy2sodubNQvLrT83Ffm8i98GDhTNrWRHtlWSwHGw6sBq
         xKyofQL0dAvlJGOthD0x763xB9iYqLceOt1cECEcZeemLv/GJawxowCi5onKzyIt2Lwm
         DfV8hxUWzigWTi5nPbiOApronZvIwb4Mm4KlVos3ymNOgKZsdx/HxSdriEeIFDS/QxET
         yatRzrw00Z6OZsRFAUy/YjPsPb7bSCx1CFQmNN7uDkd5YdvBE4ugo24lDyWxTt/Smc0Y
         aMW44QYg2F2HvYODuLDDyAgXSOW/nskthz1Aw5jdKc8LOR2mhaCsyQGuE+Orzz4cPVxz
         Ag8Q==
X-Gm-Message-State: APjAAAVb+IPmLvaH1cDFORmBX2binPclyqrJAy8kLnHPD5mu/t4Z0GwS
	RZRRvq/vQc9pz4NviRLP3zwRxka5Kj9q3vfPMr4wgGToovZAS7mHRaEOIECcnAeTZ/UmMLwNrUb
	30soNzbItg8YYVhjqRfONJrXgMb9IEw3Wgbh0DrKG9nwL/IlmDCX89mQdKyif+tbDUA==
X-Received: by 2002:a63:6f49:: with SMTP id k70mr2332474pgc.132.1553007159536;
        Tue, 19 Mar 2019 07:52:39 -0700 (PDT)
X-Received: by 2002:a63:6f49:: with SMTP id k70mr2332428pgc.132.1553007158679;
        Tue, 19 Mar 2019 07:52:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553007158; cv=none;
        d=google.com; s=arc-20160816;
        b=CtIDHmazh/CfHSXSxm12vh2vI8wpphod+0f7PLjOQR6h6NG8dNDb+ScqB0iF2rVRA1
         f3IZ5VuN3GHe89JqFAQpxKTGymGXviPEeaodyuxGXdpUn0Ir9Xtbmv8/nck6CuG9U67/
         /Dm+hs6DlDR4gWEyZUkRT9ViaM6XUN7k+IM1itr14+4vYT7l1508XbOZjF2GN2sXSh2J
         FsmQpoB9dWAARoUL3JpcDdtWbeGmJAYERiBBdDKyHv1XAJRd4qwJD4s6z+ddt6ri7m8H
         NXmj1gziRCreDlWQtIxAeouQ+EBuUKpensb9uym4LCZvxyKIbXY70uw2n57rwqY9wghx
         OgKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zB1hQjC0mgnVNeuNNiIBwxKkFopOSlcbEb5hoUvPPwk=;
        b=wHuHO8zQZfRi8BDWhzB6ijhMgqME8KZTurc6MvQ18FS7UUVn+AITV9cqXoxN4PLszU
         IW7JAIzcSu+BHbhQWhroV8I0qFnhIKWwcr3oNX8l0Vgt2vqIEUkrwTnJnw0IjO6NKVpj
         k/2otw+fKtOJZrN+Z4PTPqOQwWtU65pIJ525U2EaZBJtftoiJENHnFSK2sBIyIa7mzgu
         znXrVfxidhkNVQh2TVost6mlWm6eDntVBP5/73aRhFBS6xLjGLt8gHbI8MXvp0VfBvFs
         f5SMK2M7e6RLnUNYAaDhV2eV+owRg73M1ZygJHSWULLSGRNBocdkTpKo+KYrGMZZvGKN
         PKxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=lvB7QQql;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 204sor19219781pga.16.2019.03.19.07.52.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 07:52:38 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=lvB7QQql;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zB1hQjC0mgnVNeuNNiIBwxKkFopOSlcbEb5hoUvPPwk=;
        b=lvB7QQqlhCElCL482TG/C14Y8nu5MVqVhtscOeCAU+SVqwi8gdqJjcHmNXEMBqvbL9
         zTGSI2UBjt5hFMaeUujl4gqNzPLxX8oLmw8whaE6f+AMAGH1BUNd0CYB2qxh9TUNs9m8
         4mxbDuvL6DXFxiuBcZZ67HdelRfICluXwNr0RYqZu3IxIWb6jS5ZNwsB2Mmv8vpZsBT1
         KAlRrwS9aNytSLU4P933L4cWrhCsdRvRJlT3iNvDAy0yn5mIjjXL63vPv7fCy7uspie5
         RjoplhmM1HBYyJBcMn7bTsn3jjJxZa3Lyg2DuL2kfHOYhPSZaMFWeFti+p3iL3lydSmY
         107w==
X-Google-Smtp-Source: APXvYqySWwO/TUOVN3zBIZSEE1bvnLBCq630VZz3VSpOP7kM8CPU9+KxYOBZlb+h0fuRjwZPK0HaeA==
X-Received: by 2002:a63:450f:: with SMTP id s15mr2177246pga.157.1553007158188;
        Tue, 19 Mar 2019 07:52:38 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id n24sm32004022pfi.123.2019.03.19.07.52.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 07:52:37 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id D72133011DA; Tue, 19 Mar 2019 17:52:33 +0300 (+03)
Date: Tue, 19 Mar 2019 17:52:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Oscar Salvador <osalvador@suse.de>
Cc: Yang Shi <shy828301@gmail.com>, Cyril Hrubis <chrubis@suse.cz>,
	Linux MM <linux-mm@kvack.org>, linux-api@vger.kernel.org,
	ltp@lists.linux.it, Vlastimil Babka <vbabka@suse.cz>,
	kirill.shutemov@linux.intel.com
Subject: Re: mbind() fails to fail with EIO
Message-ID: <20190319145233.rcfa6bvx6xyv64l3@kshutemo-mobl1>
References: <20190315160142.GA8921@rei>
 <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
 <20190319132729.s42t3evt6d65sz6f@d104.suse.de>
 <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
 <20190319144130.lidqtrkfl75n2haj@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319144130.lidqtrkfl75n2haj@d104.suse.de>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 03:41:33PM +0100, Oscar Salvador wrote:
> On Tue, Mar 19, 2019 at 05:26:39PM +0300, Kirill A. Shutemov wrote:
> > That's all sounds reasonable.
> > 
> > We only need to make sure the bug fixed by 77bf45e78050 will not be
> > re-introduced.
> 
> I gave it a spin with the below patch.
> Your testcase works (so the bug is not re-introduced), and we get -EIO
> when running the ltp test [1].
> So unless I am missing something, it should be enough.

Don't we need to bypass !vma_migratable(vma) check in
queue_pages_test_walk() for MPOL_MF_STRICT? I mean user still might want
to check if all pages are on the right not even the vma is not migratable.

-- 
 Kirill A. Shutemov

