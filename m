Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6636B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 20:15:57 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id j107so15480556qga.6
        for <linux-mm@kvack.org>; Tue, 27 May 2014 17:15:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ki3si19096506qcb.29.2014.05.27.17.15.56
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 17:15:56 -0700 (PDT)
Message-ID: <53852abc.03ece50a.52f5.ffffccb3SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] memory-failure: Send right signal code to correct thread
Date: Tue, 27 May 2014 20:15:33 -0400
In-Reply-To: <CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com>
References: <cover.1400607328.git.tony.luck@intel.com> <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com> <20140523033438.GC16945@gchen.bj.intel.com> <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com> <20140527161613.GC4108@mcs.anl.gov> <5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com> <CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@gmail.com
Cc: iskra@mcs.anl.gov, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, gong.chen@linux.jf.intel.com

On Tue, May 27, 2014 at 03:53:55PM -0700, Tony Luck wrote:
> >  - make sure that every thread in a recovery aware application should have
> >    a SIGBUS handler, inside which
> >    * code for SIGBUS(BUS_MCEERR_AR) is enabled for every thread
> >    * code for SIGBUS(BUS_MCEERR_AO) is enabled only for a dedicated thread
> 
> But how does the kernel know which is the special thread that
> should see the "AO" signal?  Broadcasting the signal to all
> threads seems to be just as likely to cause problems to
> an application as the h/w broadcasting MCE to all processors.

I thought that kernel doesn't have to know about which thread is the
special one if the AO signal is broadcasted to all threads, because
in such case the special thread always gets the AO signal.

The reported problem happens only the application sets PF_MCE_EARLY flag,
and such application is surely recovery aware, so we can assume that the
coders must implement SIGBUS handler for all threads. Then all other threads
but the special one can intentionally ignore AO signal. This is to avoid the
default behavior for SIGBUS ("kill all threads" as Kamil said in the previous
email.)

And I hope that downside of signal broadcasting is smaller than MCE
broadcasting because the range of broadcasting is limited to a process group,
not to the whole system.

# I don't intend to rule out other possibilities like adding another prctl
# flag, so if you have a patch, that's would be great.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
