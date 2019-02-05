Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C991C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 15:17:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 623BE20811
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 15:17:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 623BE20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 104C38E008D; Tue,  5 Feb 2019 10:17:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B2608E001C; Tue,  5 Feb 2019 10:17:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBD4C8E008D; Tue,  5 Feb 2019 10:17:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF5488E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 10:17:21 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a19so3251504otq.1
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 07:17:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=VFbGRb5xknWLloF/iUFH3qR3GQTul32AhZ77ruSeqok=;
        b=INyVOXKs9teSO2q8ooYiFVgc9z7ONz3CtK6X9LJTX/66x7H75lRmuhu0NiLoXGAxlp
         VQ0O0Qjv6FpunP+sOCXsi4Rz8YLdTpGDjDoQKDTMou47uwJZNh4VpsQvhnnQ4DvJefFv
         DOU9KqKYjlNldUtMXpbiksMOj2wIYyvM5TJmMEoAuWqOOWlXx4NdkuGITXDK+A1PaDm6
         lJOLyoQEQHYbpZk9Yn+GFFuTU6xTKB8hBWewEycPAjVRpr8XyOBAnP3FInGPHAQAHT6I
         3YYC1HV4jumtEfJxhBeVjrM0fcTd8MeybCoQp0NAPObd6aII7jk/xUIKXJWHI//lKK14
         whQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYFfufMRLAaqVzWXRI1dFEo0vZ3FsgsUwqnHx0vuLF1d+QMU1j4
	W88awU23pbAP/iGPtWP3OdmCji6kjlu5uIpFytnEkM0Vht+iFAaAvlPmlQ2gEwAYR8StmP4ETA6
	nnrGgwNGqbky0uwdk3bxcbaYb9qjjMfX66CWn32URPIkD1l6JIEcIhnTKha+P9vV/TrLunTFL1N
	Sv96ru/uYu5KENsOuHtFD+OISX87qYTLAA0xj1vyQKBigmLbfvZiWClil+KJfvpEhOObLDzBO1O
	ZzVsuGl19SOuK/HPWW/y6Ap1sL+6pU1/NU1ShHql1lD61h8XaOQgNkKQ0NQ++BVgFkHSoVGCnA8
	1Otd+faB4SLmN4dOardtxMbWe27ozntt+bGMP5KCgY7FmOHpVJc2zrM5+2tPofrSUXsduMvMAQ=
	=
X-Received: by 2002:a9d:a2e:: with SMTP id 43mr2676603otg.8.1549379841532;
        Tue, 05 Feb 2019 07:17:21 -0800 (PST)
X-Received: by 2002:a9d:a2e:: with SMTP id 43mr2676579otg.8.1549379840810;
        Tue, 05 Feb 2019 07:17:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549379840; cv=none;
        d=google.com; s=arc-20160816;
        b=X7Inj/cSXOVmknFWfkLmTWMSOh9504tBbTjAaCQ2gKTJsTaOA9TGvfyI8AztwefKh2
         pRDjRrJ7T6gl9pS/6eqfXvtGPZI0JOQAhs0wFTkPCMEbCCeFpp8SxH0Zz9DG6iYj8eA+
         T/FWIpaCUZhoI8RIdSQUJpP+RC+bswhLOB7uE6j17tmhVC3rfRXkDdPJW64O9Pml3Dlu
         4+pVn/HcpqywKaVMWHwIARuLyARF08JmpPnKB0LeBheAuTxbAObG4eopvEh045XFUuqb
         Ag/5hpryqCZWYd1XQR65t5GUrKh6s36+98znHcDSb5iIhxwp+9XGrBzIjhY14xnbMYkQ
         9qeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=VFbGRb5xknWLloF/iUFH3qR3GQTul32AhZ77ruSeqok=;
        b=DJUn5b7H8t/yKalLWNquylGabYI3K8Kh/sTM1yOIXnxPaZmWyJgRN+sdEZlfUuDXLs
         5X+7vIv8H0/oehFWtqQvT4YDMv3mBhJO1KzL74rJOvvplmkCZoWEXC//GfTUEc/yg4Xp
         +lc1qMjnucIYutI2LhxIoH63TlKV7qDC5e8XOCpKLlJ3CqNuGOkknOA2q7ECCKi+iD7p
         r+Os/sI/DB47k5UDOyjAR6ft0N/Ip6VjGfxgXXOiMkkUOJrDTCBw5MAOWpLtPf8TCFrL
         Lusyyux5SRBjxtOSD4j7FAFZ6NcSuWC++eVyHLtvAzUqMig4ow2M38g6Q28x0dmo02tF
         K7eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor11138562otk.110.2019.02.05.07.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 07:17:20 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbBRrmwxI7rinu6UFIu6OFS1uAu7sh4Uro2X/OU7M0jdyY20EdvJCHRbVh2D22zfsNV273Xh1WPVvxgxWx3nxg=
X-Received: by 2002:a9d:588c:: with SMTP id x12mr2964645otg.139.1549379840370;
 Tue, 05 Feb 2019 07:17:20 -0800 (PST)
MIME-Version: 1.0
References: <20190124230724.10022-1-keith.busch@intel.com> <20190124230724.10022-5-keith.busch@intel.com>
 <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com> <20190205145227.GG17950@kroah.com>
In-Reply-To: <20190205145227.GG17950@kroah.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 5 Feb 2019 16:17:09 +0100
Message-ID: <CAJZ5v0g4ouD+9YYPSkoN7CRLTXYymeCaVkYNzm6Q6gGdNgJbuQ@mail.gmail.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 5, 2019 at 3:52 PM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> On Tue, Feb 05, 2019 at 01:33:27PM +0100, Rafael J. Wysocki wrote:
> > > +/**
> > > + * struct node_access_nodes - Access class device to hold user visible
> > > + *                           relationships to other nodes.
> > > + * @dev:       Device for this memory access class
> > > + * @list_node: List element in the node's access list
> > > + * @access:    The access class rank
> > > + */
> > > +struct node_access_nodes {
> > > +       struct device           dev;
> >
> > I'm not sure if the entire struct device is needed here.
> >
> > It looks like what you need is the kobject part of it only and you can
> > use a kobject directly here:
> >
> > struct kobject        kobj;
> >
> > Then, you can register that under the node's kobject using
> > kobject_init_and_add() and you can create attr groups under a kobject
> > using sysfs_create_groups(), which is exactly what device_add_groups()
> > does.
> >
> > That would allow you to avoid allocating extra memory to hold the
> > entire device structure and the extra empty "power" subdirectory added
> > by device registration would not be there.
>
> When you use a "raw" kobject then userspace tools do not see the devices
> and attributes in libraries like udev.

And why would they need it in this particular case?

> So unless userspace does not care about this at all,

Which I think is the case here, isn't it?

> you should use a 'struct device' where ever
> possible.  The memory "savings" usually just isn't worth it unless you
> have a _lot_ of objects being created here.
>
> Who is going to use all of this new information?

Somebody who wants to know how the memory in the system is laid out AFAICS.

