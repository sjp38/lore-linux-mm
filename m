Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C09BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:00:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A10720651
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:00:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A10720651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA4D16B0010; Fri, 29 Mar 2019 10:00:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7B7A6B0269; Fri, 29 Mar 2019 10:00:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C920F6B026A; Fri, 29 Mar 2019 10:00:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6ABF6B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:00:05 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 23so1805357qkl.16
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 07:00:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MIynPzRe7Z4DAsU/5DCr2hL+bCtnX+Jg0QzX1K4DsGk=;
        b=mlRZLynCwTWZTttfAZ3DdroS5U1eVXG7uVGGTSafGGwHwcAPRCUeaqgob3KFLVe+Jr
         jwFaeykR7VgtEvAgeXasmAfQBS8uwlKzbAQkFDBSJodAubAjmodM07428BObHhEugUrx
         CczASV2J2EOMfZdL+N7wZQg17rlP3CP9kvbBPck3Tgc6ZSU5Col2atRR0WugnCorvaGi
         JqsVe2/FaojdYRyKKwnCcelgIz/cPbZEWJNt4BSDpqbLgQjMhohko1sZjHoz12x14Sz0
         U2XFwAjjcRsPXJXkyJo84X72xw2uY325rGYv0LQ7ZxMkh7XUYS6Q37/tW13KSk14S7TK
         YbRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVqYARGfjs/vzxc8GBPYFFAcdLv9MWi1k7W1oB+2x2RcTf45+VU
	zBz4hfaG01E9mG2PaRURd/NWipIer/wxtZLGBDGdw8RdPO3R9KSXoJUIODXtWeCTBV6HdkNe2oN
	3u5npK1AMtuIyqk60fxPujyjZL+8l2XUpnS6Pp0QVk534xhntW2xOoxxxkGt1BzeTyw==
X-Received: by 2002:ac8:2df8:: with SMTP id q53mr40845113qta.132.1553868004888;
        Fri, 29 Mar 2019 07:00:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDkKdkPS0f+hVfGZePHsgS2HFz8wNc+MLIedzyvBElnZj1jGCUIMwB8cW8tDkjGR2rUcYt
X-Received: by 2002:ac8:2df8:: with SMTP id q53mr40845002qta.132.1553868003453;
        Fri, 29 Mar 2019 07:00:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553868003; cv=none;
        d=google.com; s=arc-20160816;
        b=pSk8PCy0hmHkvUpVqbl1P7xEWCJCjMuNfmBLye2BW5vOGJ6+MTIwlxGAWTPS7hqXSn
         ZmjIwKLPGu/lybq/PgfkT48QGtnSa9yZZHXNhHqOEsc9xiyjyL95FDFRxJj5Qa+940sv
         22w+/oFep6Gdm5FHXmS0e9oJM3FknxcVn2pS6ZUBpjjCs+qmrTIjLgQQgz0yA0jBf+Qy
         NY3fhkTzT6kiLV2Y6+gvtufJl/QplExPsL0eXLrv9FmquJ1UoyVx7yHbX5kongU6kz/z
         2z8TEoTvwjU7DJ+/6Ovm+8mlfZ/giK8YAJXKJR18B7EGGnI5O0xL4BbWVDNUfpC6hUw7
         pMzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MIynPzRe7Z4DAsU/5DCr2hL+bCtnX+Jg0QzX1K4DsGk=;
        b=PWCtoY4oPmKI7H9xWzVplyQIWFjhzPMy9qjSWocdu6JGG7KCKPmKuhNnCW9S/OPI/d
         VIBU7Cg3wZVI/+O8cPXXVTSLsAck+B81yrbnniYphbNYol2WFAtNwLziaber+7wppph0
         XYl8Ohuc84synCQX2RU7BnwZ1k62+/13/e4mHKibZUlVjpK9bXr2ta1j+qtrmowo7zOa
         sZz8BeUJHiVmHLM3VdwZt0ZvnVjwc7YJ6gY99rZQXmIbcX0Er9Rx3Fve1fwHHHyrFhKD
         3lpwcbX9voWBLCQlBakfA9OQz4tkgcslRl3kg7LBEerW4rosOwiFTMX3LdI6tdn/7Sxf
         t3Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si562848qve.128.2019.03.29.07.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 07:00:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6A0D930718E8;
	Fri, 29 Mar 2019 14:00:02 +0000 (UTC)
Received: from localhost (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AD6365D9D1;
	Fri, 29 Mar 2019 14:00:01 +0000 (UTC)
Date: Fri, 29 Mar 2019 21:59:58 +0800
From: Baoquan He <bhe@redhat.com>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rafael@kernel.org,
	akpm@linux-foundation.org, mhocko@suse.com, rppt@linux.ibm.com,
	willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 1/2] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190329135958.GL7627@MiWiFi-R3L-srv>
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329103644.ljswr5usslrx7twr@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329103644.ljswr5usslrx7twr@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 29 Mar 2019 14:00:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/29/19 at 11:36am, Oscar Salvador wrote:
> > +/**
> > + * sparse_add_one_section - add a memory section
> > + * @nid: The node to add section on
> > + * @start_pfn: start pfn of the memory range
> > + * @altmap: device page map
> > + *
> > + * This is only intended for hotplug.
> > + *
> > + * Returns:
> > + *   0 on success.
> > + *   Other error code on failure:
> > + *     - -EEXIST - section has been present.
> > + *     - -ENOMEM - out of memory.
> 
> I am not really into kernel-doc format, but I thought it was something like:
> 
> <--
> Return:
>   0: success
>   -EEXIST: Section is already present
>   -ENOMEM: Out of memory
> -->
> 
> But as I said, I might very well be wrong.

Below is excerpt from doc-guide/kernel-doc.rst. Seems they suggest it
like this if format returned values with multi-line style. While the
format is not strictly defined. I will use it to update.

*Return:
* * 0		- Success
* * -EEXIST 	- Section is already present
* * -ENOMEM	- Out of memory

The return value, if any, should be described in a dedicated section
named ``Return``.

.. note::

  #) The multi-line descriptive text you provide does *not* recognize
     line breaks, so if you try to format some text nicely, as in::

        * Return:
        * 0 - OK
        * -EINVAL - invalid argument
        * -ENOMEM - out of memory

     this will all run together and produce::

        Return: 0 - OK -EINVAL - invalid argument -ENOMEM - out of memory

     So, in order to produce the desired line breaks, you need to use a
     ReST list, e. g.::                                                                                                                           

      * Return:
      * * 0             - OK to runtime suspend the device
      * * -EBUSY        - Device should not be runtime suspended

