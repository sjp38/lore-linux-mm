Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 616B3C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:57:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3156C2086D
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:57:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3156C2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA2808E0003; Wed, 26 Jun 2019 02:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A53B88E0002; Wed, 26 Jun 2019 02:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 942738E0003; Wed, 26 Jun 2019 02:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 411E48E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:57:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k15so1699174eda.6
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SFBeovEuKLrWU5602hTt3utRcD7rSZEU1pi8JjcMQtI=;
        b=o6YkBpGVSoL/DF4Ax2CG8fSKX6iUnGjjKViIkCp3Oak/EFkRM+OMi0V4vb0jjcIb6G
         8LIQ0MeNeexZBkjwBOaPQE9YGQRmLk+PMOQUgdIhL8OgMQv/HzrddXmGXegjK3HFWZNO
         iUVXnpYnCuX2Qp6NOlkL8vuCFZwL/jeb8IcB8fqkzwmQI9J3vmcGytTd66J87FoS8/3T
         Jk+8+Jg82+RupOy8KwFZ8TRvIQQF9AclYLTT8zL++krWMqNRy062oEBSWpbK1xJ6jWXp
         yWvCdpq38mN8T8j0r1l7dqt0qveBFg2V5P0dFvWSI3oqQbFO3KzucQNoAuSi36GIm+uF
         oR6A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUJSGUTQ5X3/Gz+Z7uszWE8tvY9yvSQVNbXYUMBwlYbHlmQo4+W
	oy0swEW9F50xYhd5G5s+Fn1mmW8B+C33+Vzl99cjJApHFffRmrw8PU5l7IGR81F3HXiHOfzClKb
	uxZ+BWL87KtkmwRomkGavG5PBv4p1zmSsD+eo6BGqPwFJBmLp4exSeaU+AGkLIyY=
X-Received: by 2002:a17:906:fcb8:: with SMTP id qw24mr2468138ejb.239.1561532273834;
        Tue, 25 Jun 2019 23:57:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxxpi5IvDJj5DeGwYoOE8/8MRbvEbbwvhXmwpHLoGaRnebMfCpO5MEeFgNpwPzWe/Ry1fl
X-Received: by 2002:a17:906:fcb8:: with SMTP id qw24mr2468090ejb.239.1561532273051;
        Tue, 25 Jun 2019 23:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561532273; cv=none;
        d=google.com; s=arc-20160816;
        b=hktTBVZQ0areTqNTv4SPmoLPUwPftZRZfu2UEm5MPXgt1vFuzWnTJdGLxSV8GqADfv
         63acTyDhtZ4OHKgf7XCDcZ0aYgU+ctBT3Y8cRunqHhE6Cu7OGt3PsyW+HZ1eJF8I0HWy
         W55leZ9XCqXShUx14k86nEcpRUsAUqDfhbLkxhzhh87ZdMGOcWUssxaSQ4TkF8oDU7vc
         XvP+/Ubbhst6DPbGM7P6z8HTIVoq/HF32xhZnVLBWUO80o3WVKtE338l5eKmxP9JQIQO
         syW5Yl9lfBHphzmZWAtgHOShZgEXLpIzAZi/5kTZbAfN50Hy7sQvvrkAuOmYzYduAx/E
         m/OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SFBeovEuKLrWU5602hTt3utRcD7rSZEU1pi8JjcMQtI=;
        b=jczCe8HpSjzKFIv2OtPeq9WC8zwuWdyp4YAJucz81u2scDYdZHN64wUA3G/Gs1DVuD
         acKHyTEWepeLI2hpyicZZs6BrIZ1F8Ox6RdJOuhONLmHrBzdC4z5gqRUr1e/TNuHmvIj
         JgcE7sx7hjs8j9AVdEf+6qtPU3d51lmOpIg4qxSZK8XvRFjjYtyjjo8mcXUmPUQ869pY
         ejoHf/jLber4LJbvuKJ3+QaefoEXasDQVACqaz3/mfijRxYD5YvuDLI30iZc6kqGg+b4
         CC/U5/rjNj2HMYmzDq75cWUSbJJjNUVTjXUy4PNtGN74kJLSu1nYkajosDWoQqfMOPT6
         n5uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m11si1906946eje.369.2019.06.25.23.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:57:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6A6E5AF96;
	Wed, 26 Jun 2019 06:57:52 +0000 (UTC)
Date: Wed, 26 Jun 2019 08:57:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
Message-ID: <20190626065751.GK17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-2-alastair@au1.ibm.com>
 <20190626062113.GF17798@dhcp22.suse.cz>
 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 16:27:30, Alastair D'Silva wrote:
> On Wed, 2019-06-26 at 08:21 +0200, Michal Hocko wrote:
> > On Wed 26-06-19 16:11:21, Alastair D'Silva wrote:
> > > From: Alastair D'Silva <alastair@d-silva.org>
> > > 
> > > If a memory section comes in where the physical address is greater
> > > than
> > > that which is managed by the kernel, this function would not
> > > trigger the
> > > bug and instead return a bogus section number.
> > > 
> > > This patch tracks whether the section was actually found, and
> > > triggers the
> > > bug if not.
> > 
> > Why do we want/need that? In other words the changelog should contina
> > WHY and WHAT. This one contains only the later one.
> >  
> 
> Thanks, I'll update the comment.
> 
> During driver development, I tried adding peristent memory at a memory
> address that exceeded the maximum permissable address for the platform.
> 
> This caused __section_nr to silently return bogus section numbers,
> rather than complaining.

OK, I see, but is an additional code worth it for the non-development
case? I mean why should we be testing for something that shouldn't
happen normally? Is it too easy to get things wrong or what is the
underlying reason to change it now?

-- 
Michal Hocko
SUSE Labs

