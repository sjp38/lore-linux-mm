Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C34756B0255
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 14:49:18 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so31002616wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 11:49:18 -0700 (PDT)
Received: from sipsolutions.net (s3.sipsolutions.net. [5.9.151.49])
        by mx.google.com with ESMTPS id h8si6099731wiy.93.2015.09.25.11.49.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 11:49:17 -0700 (PDT)
Message-ID: <1443206945.2161.9.camel@sipsolutions.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 25 Sep 2015 20:49:05 +0200
In-Reply-To: <20150925184741.GF5951@linux> (sfid-20150925_204744_507179_F4A02CF2)
References: 
	<e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	 <1443202945.2161.8.camel@sipsolutions.net> <20150925184741.GF5951@linux>
	 (sfid-20150925_204744_507179_F4A02CF2)
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org


> Rafael wrote:
> > Actually, what about adding a local u32 variable, say val, here and 
> > doing
> > 
> > >  	if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32 
> > > *)&first_ec->gpe))
> > >  		goto error;
> > >  	if (!debugfs_create_bool("use_global_lock", 0444, 
> > > dev_dir,
> > > -				 (u32 *)&first_ec->global_lock))
> > > +				 &first_ec->global_lock))
> > 
> > 	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir, 
> > &val))
> > 
> > >  		goto error;
> > 
> > 	first_ec->global_lock = val;
> > 
> > And then you can turn val into bool just fine without changing the 
> > structure
> > definition.

Ok, then, but that means Rafael is completely wrong ...
debugfs_create_bool() takes a *pointer* and it needs to be long-lived,
it can't be on the stack. You also don't get a call when it changes.

If you cannot change the struct definition then you must implement a
debugfs file with its own read/write handlers.

johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
