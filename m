Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B919C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:42:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 092F420856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:42:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 092F420856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EB6C6B0005; Tue, 26 Mar 2019 08:42:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 598F86B0006; Tue, 26 Mar 2019 08:42:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B0806B0007; Tue, 26 Mar 2019 08:42:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9806B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:42:51 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 75so11438662qki.13
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:42:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mjO9JIKbuRYeT7pWTYRoMObVicv1CYjqH0QebUzFQhw=;
        b=SreLHprdBBduZYbNl3orFo8FR6CJ9JYFLNrzxYy9W9RTKsfCSpDZA4aIIJPUDWaeUD
         z4v/uNzB1ZOHAOr6Sg62bV+ee0pZbNjzzai7NZaSQMV9TdDE8Ns30jxgrC6DLZW8Ietr
         CI9XOPTF1gA3/l5vaeCRzapubdIT0Jo9ZOUi4FmqHofn1a064kGK0jwLKmDJ7l5O8n2q
         Ne/Ww5iyUNnDq/u9wwDXXnib5uIxsaWIaguS3gdfz72OzvDZ9ZAh4CN5hz7zDssikv0j
         XdiYhyVxwNT/RY7W1McJu4NgTEaN77OzZq8as0gFxn+iyW3GDmJlYndilYhLeS6KZrWr
         hL9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXpOu1YGj6mra3ogKE+LvdhrmiC7+i/g89xDVzrVL1i4ak0X+ac
	TWnl8RVe16HHzVLmrC3Xk+IoKFI3v0hLlxUDgtWmdwn51ebHIWTRZOlB4/UIQa9cXMVp6yhu3k/
	wpkWCiv0IMyfyl7Dldc8gcKR1bZUri2dsZCxg+3/xqqiE4uNOyRw66ogHWOeeiMOhkg==
X-Received: by 2002:a0c:85a4:: with SMTP id o33mr1881844qva.105.1553604170925;
        Tue, 26 Mar 2019 05:42:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZv1aIGfxozISj8Jp+dW+41o5e3vmQbrnoJj1zJCyRf09Ht9scscbvgzQXhVii3GaaC4wv
X-Received: by 2002:a0c:85a4:: with SMTP id o33mr1881806qva.105.1553604170461;
        Tue, 26 Mar 2019 05:42:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553604170; cv=none;
        d=google.com; s=arc-20160816;
        b=0ih4+jSIRilPmR6n9wDuCjVKTlrhiG19x5ak6HL+QavgLgGth+Aw5y0iQSL0q4/ipA
         UjcNpxa12CV0r6iCMXr/FvFbNAcVqRPzvB0eH4TKB9nqPO4G++dEBnVnP597Obbma6Tk
         ua80MYlv50jSkQpeFTRMSSXWTHBWRmiT8lDcmKEJPEMLoOOYmgW01LrG5FAmm86XLsPR
         7s7thULn+sMZlQ0yYa3Bvc8xwNVlHA1q/yzfvzkIPZP55gJh6ofwRkCQU33a4ZvlGriI
         WpYsq/cNtr+vPijl4SjNjYNSfCpq8uY5BML21G2kQu/vBvBP3ojnMj6ACMdpZezEBJEN
         3aZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mjO9JIKbuRYeT7pWTYRoMObVicv1CYjqH0QebUzFQhw=;
        b=UEfmO2G98L6Y7A9GZSEi2AiAf8Lg0HUwO5h/sXEreoYHJBm3F0T1ZY4ilKk+HniJo/
         WcLol7DZkfmwC44proFDcYP2BH4gP2h/vk4Sb7CvfQgXc0Z9cNHx7lNADaNOFEteE8OZ
         nV3sARSmYrxUbjCfYMoyyWavJDLWUV0hVCrLKckgNeFt0KPqMUuhTTjItOqd8MUsQQrF
         vif7yZEbV5/Z4wx3XA3nKAkNsiw1vx0boV5O4HpGK8RuqemiiqpJfZu2j9jcPQFuHvWU
         mA0dfNVU3BaNXB4qOK6xj6n2yxYdgsReRR312bIWW0tS73KUdJ79FrBm+CYVD9t1B6Xh
         7ehw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w5si723431qvf.122.2019.03.26.05.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 05:42:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7C00C301EA81;
	Tue, 26 Mar 2019 12:42:49 +0000 (UTC)
Received: from localhost (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 80B0B91D8B;
	Tue, 26 Mar 2019 12:42:48 +0000 (UTC)
Date: Tue, 26 Mar 2019 20:42:45 +0800
From: Baoquan He <bhe@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, mhocko@suse.com, rppt@linux.ibm.com,
	osalvador@suse.de, william.kucharski@oracle.com,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH v2 4/4] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190326124245.GA21943@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-5-bhe@redhat.com>
 <20190326114358.GM10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326114358.GM10344@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 26 Mar 2019 12:42:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/26/19 at 04:43am, Matthew Wilcox wrote:
> On Tue, Mar 26, 2019 at 05:02:27PM +0800, Baoquan He wrote:
> > The input parameter 'phys_index' of memory_block_action() is actually
> > the section number, but not the phys_index of memory_block. Fix it.
> 
> >  static int
> > -memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
> > +memory_block_action(unsigned long sec, unsigned long action, int online_type)
> 
> 'sec' is a bad abbreviation for 'section'.  We don't use it anyhere else
> in the vm.

Hmm, here 'sec' is in a particular context, we may not confuse it with
other abbreviation. Since Michal also complained about it, seems an
update is needed. I will change it to start_section_nr as Michal
suggested. Thanks.

> 
> Looking through include/, I see it used as an abbreviation for second,
> security, ELF section, and section of a book.  Nowhere as a memory
> block section.  Please use an extra four letters for this parameter.



