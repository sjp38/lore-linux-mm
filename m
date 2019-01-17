Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09DECC43444
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 15:09:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C725120851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 15:09:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C725120851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 643E28E0008; Thu, 17 Jan 2019 10:09:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C9FC8E0002; Thu, 17 Jan 2019 10:09:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46ACD8E0008; Thu, 17 Jan 2019 10:09:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 164C98E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:09:45 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id n22so4938726otq.8
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:09:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=MXqGV/xla3Lhq8q8Yrhbnz5xbjK0BhIgvFY3XkA7gnc=;
        b=MN8QjgBBD8FDWOiauYRi+fzAE5gYxvoY41F+WnlHnHJvYrtZVCRXUHT0jVCM1BXr0c
         rNYj0O0DoAQmmGx9rIoHzCZT35043GMSVaujLpuVTLG2OVBrk9/sQuR6JlVeDQVbxvNP
         Rc2ZHrOiY9SbOErNcQoOaMKdsjmTJBwTPhwbwUQjmv2SUTdtyjGZAXGURuOcq4gGFzYC
         Fg4tsgKWQUqdVka3P2FUCfv2QoDjqoJbCTmCECvvXjnUMnU5yG9z6LIXAsubfgPfzjKJ
         j/MVPzi4S4i/uq6Oghc5mWA7jUKUFjWANFwtPq9ZORuh2tODVV9sFyR/7YVoFq0THATy
         frbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUuketernt2ebu+SmWMgXZ+N5wCwLkpsJDGS8firaqH0gfXeO2ehiO
	kZKfuApNIeXSCUkEczwhIXwhhjF3z7RbS/dDuXtLSaBrH1h7QJU4zgDijVRY9TZfIRopYdiSqOt
	gVE17+wcCbiVUKybWNBNKxZsOGid0Ms/HXWy6+uLRM5fBrooK1KeUN9kQjNgYL67CqjbVGgfvLj
	rmJah0zb3L0WhsMeVuDXgh1SJZRoM4zU44bOUmNvbhXUFek+0Oh2NYxD8iO87efpKsliEC3dQeV
	S7o80MRw1zzWorYrQ6+z//mNYf3WinrcYNxfuetcuPvGfYTPJt6dXS/ltfQzuFxQlcWS5jqdko1
	0EGnl7anZZRxJdC5WSHU6v/kosHiq+2Ly5ewcC01dfKta1pVjN+yBl5FsAUfqWo5xRQ54CdbZQ=
	=
X-Received: by 2002:aca:ab16:: with SMTP id u22mr463656oie.249.1547737784845;
        Thu, 17 Jan 2019 07:09:44 -0800 (PST)
X-Received: by 2002:aca:ab16:: with SMTP id u22mr463627oie.249.1547737784137;
        Thu, 17 Jan 2019 07:09:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547737784; cv=none;
        d=google.com; s=arc-20160816;
        b=mPfILZ74/AnKvnsDYmdMZCLPH3FXEXQhTTzmfqPlN2Dz/eCHuqMRrYAsKSsf5pXUER
         YXhjG7lpHvgBGZvcNnz5VxB1KL5qSK8+QIhNeyUK3pigRkNNii+z0jQs1pBgbt1+IoqV
         2bIFdCig64rUe2Rd7UI5bQ8LgdLJEVRSBNzFIKNShbTxbPyYtSUEJ0PJxM9eNI+7lLGA
         MxE7mVg4TG1ALI8fAzo4XKNLU7F0PiqcXGr0nxcIFz3md12OnOw1htslGHIDfdWrHojy
         H27VDwHX4cqn02hieqPyNHu59m/SpEvsPKWhFnHp1AIgcW+F615ItQG6J5f/HRxtKAH8
         KRdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=MXqGV/xla3Lhq8q8Yrhbnz5xbjK0BhIgvFY3XkA7gnc=;
        b=sru730xM10ViQ2L567xQZdCMY2o1eHjI+0I/pkRzN6nDsgeUYgQyG8m6k/OiNcozce
         XStu0VumaR50YmsoEyGJ4K/nyqaO+6YnR4eOk6+gfJUpJk0z8mLdEb4bPEzylDr/fgKD
         EDQzVcjbtNE3YW0SiKiZyVoK+s+KglOLjF2yDvFqOfEQ1A/sc6XwRFRapxXTjCwLS8PN
         770dSkeCJmcrW8unAp8/OI8zBMdMMWG436fDEeGfSROu7RhJbFlvUrqSBhRfhPBjx0sn
         9smxn2zaIwO5oe72e6XrclPiV+74dDvWVjyaUwu0uel725pmyEAUG+qKeeNMcB5/dnR9
         bK5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a143sor915193oii.66.2019.01.17.07.09.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 07:09:44 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN5iFWUYbgDOG/UTcz6q3HXMcrxIhKQkd494ya5hnftBkGkju87jPfTZfqvKeR58HAGoYm8AZcuaQtrdZXuxqho=
X-Received: by 2002:a54:4d01:: with SMTP id v1mr638235oix.246.1547737783643;
 Thu, 17 Jan 2019 07:09:43 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-9-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-9-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 16:09:32 +0100
Message-ID:
 <CAJZ5v0iV8qt3_1BP_4fPN77CC7yLXT4QMW=q+jWdts+e5rf8dg@mail.gmail.com>
Subject: Re: [PATCHv4 08/13] Documentation/ABI: Add node performance attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117150932.RDqd3q-NAkCyTkmsSkNtcf8phj48bFB_NCtALEhFbYc@z>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Add descriptions for memory class initiator performance access attributes.

Again, I would combine this with the previous patch.

> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index a9c47b4b0eee..2217557f29d3 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -114,3 +114,31 @@ Description:
>                 The node list of memory targets that this initiator node has
>                 class "Y" access. Memory accesses from this node to nodes not
>                 in this list may have differet performance.
> +
> +What:          /sys/devices/system/node/nodeX/classY/read_bandwidth
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's read bandwidth in MB/s available to memory
> +               initiators in nodes found in this class's initiators_nodelist.
> +
> +What:          /sys/devices/system/node/nodeX/classY/read_latency
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's read latency in nanoseconds available to memory
> +               initiators in nodes found in this class's initiators_nodelist.

I'm not sure if the term "read latency" is sufficient here.  Is this
the latency between sending a request and getting a response or
between sending the request and when the data actually becomes
available?

Moreover, is it the worst-case latency or the average latency?

> +
> +What:          /sys/devices/system/node/nodeX/classY/write_bandwidth
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's write bandwidth in MB/s available to memory
> +               initiators in nodes found in this class's initiators_nodelist.
> +
> +What:          /sys/devices/system/node/nodeX/classY/write_latency
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               This node's write latency in nanoseconds available to memory
> +               initiators in nodes found in this class's initiators_nodelist.
> --

Same questions as for the read latency apply here.

