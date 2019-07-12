Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 250E7C742B9
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8C8F208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:12:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8C8F208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8963E8E0142; Fri, 12 Jul 2019 08:12:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 874D18E00DB; Fri, 12 Jul 2019 08:12:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 735B38E0142; Fri, 12 Jul 2019 08:12:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 298048E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:12:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so7652379edu.19
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:12:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Axn+tcbCVS4VB+6EA18FzJgj9btgpTG5Xlu8KdrtBow=;
        b=i7cxXWKMV+TUErh7U75ImPf8iaA/Aafu5NVTB1c91MNa+Df9ldiDnJrr29FQU7c95p
         xgRcdfCb90y30Hhjqbkm4LmuEHX7khm5WYsNSxcjjHhoXVViK0hj4hDXYVO6ilye46y2
         QRg5FkuCAdh6yD4tmMkN0QafIEQ7LRT7Rx1edT1I7IBX6aTKjrLRhUTTU6mwebOBmVRp
         +IoTYE6RW1yNUdiHjd+TTTpe3vjy0LidDuOHTMIJjEvTHE5y/atBi1VLd9AlpPpJKhny
         44a7Ds5TJvkME8ISAUVx2IM4D4/YX9Nh4RCTQQYFXecvF8HPFs4ogT4f6mlQttGLIWjK
         welQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAViAACFNw9z/YivpSVeCI0EVl9ODS72N1JHM4KYq8RQFOr2kwcH
	Pa88FhiikqDHmNoHI7Tx7nnyAqxMB9rUd95KzqdvxyeFMfnXmgVDdinpZGO5lydtdK3tRzv8BxW
	dNcnCmDL/QK/xj6zttQBqSMvKr9Jm7zDSjvQkxLuLJikJ8MHVTD1uM+eCjajfXv0=
X-Received: by 2002:a17:906:3612:: with SMTP id q18mr8067491ejb.278.1562933549747;
        Fri, 12 Jul 2019 05:12:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxY7X7+g/l1rcpJeBphdL1GijId7DHflKZS9wba5DkzEWS+ap5aRP18SlesOuJ5bn6xcMOM
X-Received: by 2002:a17:906:3612:: with SMTP id q18mr8067440ejb.278.1562933549094;
        Fri, 12 Jul 2019 05:12:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562933549; cv=none;
        d=google.com; s=arc-20160816;
        b=tQRwQN3j9WGuHzlb6wTSsPnxJ2QSSptsPwIU0tq27TZS0c36VR/llE9szx+7UhtxMT
         KF1042rBjpF6mpEFwbSJvi4OjDidlnCT5Jm1X/szdpUsN9RSfLkEQYUECHyNClQWm+jG
         hRzuNBTiXKJw+h4Y6K3QFDIwL2NB9kxkgNP/ws4nxcyag3iExuVaLlF1lmPwOwEHamxi
         8yEOkr/1C3XXUao08oR4RHbS2YDgJ0r1Xqdt+WkiFyBNUgTFFty+4ZUNuc5YjRMslUIX
         UUWZVX0iVROZ5ruh6CSX3ZipKKcSB4zUDlLCswlvzvXgKyIbJmG8xr19vOLTDNahbw5f
         750g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Axn+tcbCVS4VB+6EA18FzJgj9btgpTG5Xlu8KdrtBow=;
        b=IIsS9tBrHohXKXLv5aD80xEtdStthW4O6ajLLzHie53Dlf65A/aYW1Myx5RwbfAY1E
         TSLAQR58FQ1sLOXd9y2Hq7WpfHh6HxArN0o47WW4M6tOE0TjW8Wkci5YJNdReRCMZAsY
         b/wjOOUAZd12zzvAOuxnB9X2rnWlmuuOo0IqIsi3mJ00DJCCa7pdUjSwElsP0+EKI03T
         ZVNLe8Vj08rBNmX+Udwh+7WTpi6yEiWprUiKVWp2GOHFOzA9/0QJdgqSc1Kt8dyGrfCl
         wmNNvmNTi9NWxgWxaux3gK8cPl1yzk0edh2kUoJhluODY1GZcxWFMkmUgLWCuwtxQoeV
         mslA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6si5586468eda.197.2019.07.12.05.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 05:12:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BEA91ACA8;
	Fri, 12 Jul 2019 12:12:27 +0000 (UTC)
Date: Fri, 12 Jul 2019 14:12:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hoan Tran OS <hoan@os.amperecomputing.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	"David S . Miller" <davem@davemloft.net>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Open Source Submission <patches@amperecomputing.com>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190712121223.GR29483@dhcp22.suse.cz>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-07-19 10:56:47, Hoan Tran OS wrote:
[...]
> It would be good if we can enable it by-default. Otherwise, let arch 
> enables it by them-self. Do you have any suggestions?

I can hardly make any suggestions when it is not really clear _why_ you
want to remove this config option in the first place. Please explain
what motivated you to make this change.
-- 
Michal Hocko
SUSE Labs

