Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 533F26B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 14:47:44 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so115018847pac.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 11:47:43 -0700 (PDT)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com. [209.85.220.45])
        by mx.google.com with ESMTPS id oj5si7317746pab.238.2015.09.25.11.47.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 11:47:43 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so115018532pac.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 11:47:43 -0700 (PDT)
Date: Fri, 25 Sep 2015 11:47:41 -0700
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
Message-ID: <20150925184741.GF5951@linux>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
 <1443202945.2161.8.camel@sipsolutions.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1443202945.2161.8.camel@sipsolutions.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On 25-09-15, 19:42, Johannes Berg wrote:
> On Fri, 2015-09-25 at 09:41 -0700, Viresh Kumar wrote:
> 
> > Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> > ---
> > V3->V4:
> > - Create a local variable instead of changing type of global_lock
> >   (Rafael)
> 
> Err, surely that wasn't what Rafael meant, since it's clearly
> impossible to use a pointer to the stack, assign to it once, and the
> expect anything to wkr at all ...

Sorry, I am not sure on what wouldn't work with this patch but this is
what Rafael said, and I don't think I wrote it differently :)

Rafael wrote:
> Actually, what about adding a local u32 variable, say val, here and doing
> 
> >  	if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32 *)&first_ec->gpe))
> >  		goto error;
> >  	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir,
> > -				 (u32 *)&first_ec->global_lock))
> > +				 &first_ec->global_lock))
> 
> 	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir, &val))
> 
> >  		goto error;
> 
> 	first_ec->global_lock = val;
> 
> And then you can turn val into bool just fine without changing the structure
> definition.

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
