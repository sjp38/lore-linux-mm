Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2930C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 14:48:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 971122077B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 14:48:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 971122077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B01B8E008B; Tue,  5 Feb 2019 09:48:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 339438E001C; Tue,  5 Feb 2019 09:48:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D8D48E008B; Tue,  5 Feb 2019 09:48:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC7888E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 09:48:50 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v12so2543652plp.16
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 06:48:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bLH6uwFWigGwvkOESLoN+U+TL9h+AfCEQtPwrO6HcQE=;
        b=uAAGS64tj7zBn8WjH+PVnYCcT3y7Xw8nPD6grgtDFLa7BtuJQ/RBRBKmNk+tqLWzot
         YZjeSHUXBYuCEiRqPJTXleOkTbNWIJfuCZn1PNsZljtlx2Xd5cie9V2F88e2qhYI+5zB
         9MLvakTg06TdIF5n85LnlwpTkbIlGsKnfh8NidnEpZEk5ICDUGied6dbQWlD9vlFiO7a
         hz/Kqi/+m8WRr17URSDCXjh7fl/ZoOLUeRbGv1PcVhMHNDzJPtpyB+kzvLt7uy6IulDn
         rVk9Hty//FPOnb4Vgp6L+32CQCyj0cvyUyBUULpKQ07unHLbSA99nKoo+ZW9AdOJZ8C5
         r5mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYguWFKatvH2gu99yynCqZtnQlMze2NQt5jOr4UNUuol2GnbrgS
	FEv5q9PALgRsJImEivnJXA/JIfj2rg+PKG/3kDi82o4uEOpvLys10IfYHZn4BNF1hhHEzZsHVVg
	5TIOHg/KXzl4tq55tv+B/idvtHEdeWQFxqt4VdyXwNIoy6Jy7PpUhHodnbRO2Mys4Qg==
X-Received: by 2002:a63:2ccb:: with SMTP id s194mr4884322pgs.214.1549378130420;
        Tue, 05 Feb 2019 06:48:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYduvIGBjk8teS7zuF7iYT+GfiuAbL5dyDt0m5ZV8mOjz4X74xkxsVtydDgibDaskp2W55Y
X-Received: by 2002:a63:2ccb:: with SMTP id s194mr4884259pgs.214.1549378129619;
        Tue, 05 Feb 2019 06:48:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549378129; cv=none;
        d=google.com; s=arc-20160816;
        b=GVFQMFhUiEBDid55pMm+JtDWicTn5akIf2h5T+0VmhJ6euWDn4cexIsvLHE/nrJNt/
         6k7LoL3x6xeVOBz0T1/Wo2O+CgkmiSNLvIG3xxI4PaChComK7bzrsk95kqGGB8rudPl5
         ax+Rgdr/4jNuORNmwXmlVhIqwHtbjeEr/9rywpVZf0teXFftfv8GOlo8O9NWMz5rLIKr
         oTKAviAyboMmqVUD8ZLmGWdtJOWdIe+Iwn3aQ34To1HjU+nUM/8pluuw00fhvxdy9Eic
         meI8FMOtvbP2ZcxAF9DB1jpBljpqzA3gF/Dv5fV9sgpk53NJM/TkDRBY5+XbrrgVCAmi
         jQjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bLH6uwFWigGwvkOESLoN+U+TL9h+AfCEQtPwrO6HcQE=;
        b=QH2DSVhAWM4zNwbZZ/E1as9x7lAqGQYthvfU9v+6n16+KjxKYz177ZmJy3E3eYayjS
         gJzNgYwXg/cF7FFFmFNoSb1+49KnAUax97dWVU8eads6MdXzIrGAtk5BjvtQC9FFepru
         HT3ZQTIMuZFJ+hJIy3nRHirr51okAZTYK5UmbjfE1/fqOHHwoen9j4GYg1WZP0ZY4M62
         Z9F/0E7rO9Lp9ybic3OnkUWC/LggE0W1n241OQ+dJBf1RK0b/Kx2xeiy5gMUdGvn+ScU
         oTTfNJp7SayXQTvTqAbWjk48MVaUglz0SSBeyiNah/rR0A7iFwb7IYqS7LmaIdh0WUEe
         XfQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id j187si1898412pfg.160.2019.02.05.06.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 06:48:49 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 06:48:49 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,564,1539673200"; 
   d="scan'208";a="115431231"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 05 Feb 2019 06:48:48 -0800
Date: Tue, 5 Feb 2019 07:48:15 -0700
From: Keith Busch <keith.busch@intel.com>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
Message-ID: <20190205144815.GA28023@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190124230724.10022-5-keith.busch@intel.com>
 <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 04:33:27AM -0800, Rafael J. Wysocki wrote:
> On Fri, Jan 25, 2019 at 12:08 AM Keith Busch <keith.busch@intel.com> wrote:
> > +/**
> > + * struct node_access_nodes - Access class device to hold user visible
> > + *                           relationships to other nodes.
> > + * @dev:       Device for this memory access class
> > + * @list_node: List element in the node's access list
> > + * @access:    The access class rank
> > + */
> > +struct node_access_nodes {
> > +       struct device           dev;
> 
> I'm not sure if the entire struct device is needed here.
> 
> It looks like what you need is the kobject part of it only and you can
> use a kobject directly here:
> 
> struct kobject        kobj;
> 
> Then, you can register that under the node's kobject using
> kobject_init_and_add() and you can create attr groups under a kobject
> using sysfs_create_groups(), which is exactly what device_add_groups()
> does.
> 
> That would allow you to avoid allocating extra memory to hold the
> entire device structure and the extra empty "power" subdirectory added
> by device registration would not be there.

This is conflicting with Greg's feedback from the first version of
this series:

  https://lore.kernel.org/lkml/20181126190619.GA32595@kroah.com/

Do you still recommend using kobject?

