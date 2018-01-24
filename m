Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E1AC7800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 23:31:26 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id x140so1608987oix.2
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 20:31:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b40si751118otj.280.2018.01.23.20.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 20:31:26 -0800 (PST)
Date: Wed, 24 Jan 2018 06:31:14 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v22 2/3] virtio-balloon:
 VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20180124063009-mutt-send-email-mst@kernel.org>
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com>
 <1516165812-3995-3-git-send-email-wei.w.wang@intel.com>
 <20180117180337-mutt-send-email-mst@kernel.org>
 <5A616995.4050702@intel.com>
 <20180119143517-mutt-send-email-mst@kernel.org>
 <5A65CA39.2070906@intel.com>
 <5A67FB10.2050201@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A67FB10.2050201@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: yang.zhang.wz@gmail.com, virtio-dev@lists.oasis-open.org, riel@redhat.com, quan.xu0@gmail.com, kvm@vger.kernel.org, nilal@redhat.com, liliang.opensource@gmail.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, pbonzini@redhat.com, akpm@linux-foundation.org, virtualization@lists.linux-foundation.org

On Wed, Jan 24, 2018 at 11:18:40AM +0800, Wei Wang wrote:
> On 01/22/2018 07:25 PM, Wei Wang wrote:
> > On 01/19/2018 08:39 PM, Michael S. Tsirkin wrote:
> > > On Fri, Jan 19, 2018 at 11:44:21AM +0800, Wei Wang wrote:
> > > > On 01/18/2018 12:44 AM, Michael S. Tsirkin wrote:
> > > > > On Wed, Jan 17, 2018 at 01:10:11PM +0800, Wei Wang wrote:
> > > > > 
> > > > > > +        vb->start_cmd_id = cmd_id;
> > > > > > +        queue_work(vb->balloon_wq, &vb->report_free_page_work);
> > > > > It seems that if a command was already queued (with a different id),
> > > > > this will result in new command id being sent to host twice,
> > > > > which will
> > > > > likely confuse the host.
> > > > I think that case won't happen, because
> > > > - the host sends a cmd id to the guest via the config, while the
> > > > guest acks
> > > > back the received cmd id via the virtqueue;
> > > > - the guest ack back a cmd id only when a new cmd id is received
> > > > from the
> > > > host, that is the above check:
> > > > 
> > > >      if (cmd_id != vb->start_cmd_id) { --> the driver only queues the
> > > > reporting work only when a new cmd id is received
> > > >                          /*
> > > >                           * Host requests to start the reporting
> > > > by sending a
> > > >                           * new cmd id.
> > > >                           */
> > > >                          WRITE_ONCE(vb->report_free_page, true);
> > > >                          vb->start_cmd_id = cmd_id;
> > > >                          queue_work(vb->balloon_wq,
> > > > &vb->report_free_page_work);
> > > >      }
> > > > 
> > > > So the same cmd id wouldn't queue the reporting work twice.
> > > > 
> > > Like this:
> > > 
> > >         vb->start_cmd_id = cmd_id;
> > >         queue_work(vb->balloon_wq, &vb->report_free_page_work);
> > > 
> > > command id changes
> > > 
> > >         vb->start_cmd_id = cmd_id;
> > > 
> > > work executes
> > > 
> > >         queue_work(vb->balloon_wq, &vb->report_free_page_work);
> > > 
> > > work executes again
> > > 
> > 
> > If we think about the whole working flow, I think this case couldn't
> > happen:
> > 
> > 1) device send cmd_id=1 to driver;
> > 2) driver receives cmd_id=1 in the config and acks cmd_id=1 to the
> > device via the vq;
> > 3) device revives cmd_id=1;
> > 4) device wants to stop the reporting by sending cmd_id=STOP;
> > 5) driver receives cmd_id=STOP from the config, and acks cmd_id=STOP to
> > the device via the vq;
> > 6) device sends cmd_id=2 to driver;
> > ...
> > 
> > cmd_id=2 won't come after cmd_id=1, there will be a STOP cmd in between
> > them (STOP won't queue the work).
> > 
> > How about defining the correct device behavior in the spec:
> > The device Should NOT send a second cmd id to the driver until a STOP
> > cmd ack for the previous cmd id has been received from the guest.
> 
> 
> Thanks for the comments, and I adopted most of them in the new posted v23
> patches. The above discussion is the one that I haven't included. If you
> could still see issues in the above analysis, please let me know. Thanks.
> 
> Best,
> Wei
> 
> 
>

Yes, I think you should just fix the race in the driver.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
