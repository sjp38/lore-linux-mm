Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 942206B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 08:26:27 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id v8so8086233otd.4
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 05:26:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v188si2789629oif.483.2017.11.15.05.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 05:26:26 -0800 (PST)
Date: Wed, 15 Nov 2017 15:26:12 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v17 6/6] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20171115152307-mutt-send-email-mst@kernel.org>
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
 <1509696786-1597-7-git-send-email-wei.w.wang@intel.com>
 <5A097548.8000608@intel.com>
 <20171113192309-mutt-send-email-mst@kernel.org>
 <5A0ADB3B.4070407@intel.com>
 <20171114230805-mutt-send-email-mst@kernel.org>
 <5A0BB8EE.4050402@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A0BB8EE.4050402@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, Nitesh Narayan Lal <nilal@redhat.com>, Rik van Riel <riel@redhat.com>

On Wed, Nov 15, 2017 at 11:47:58AM +0800, Wei Wang wrote:
> On 11/15/2017 05:21 AM, Michael S. Tsirkin wrote:
> > On Tue, Nov 14, 2017 at 08:02:03PM +0800, Wei Wang wrote:
> > > On 11/14/2017 01:32 AM, Michael S. Tsirkin wrote:
> > > > > - guest2host_cmd: written by the guest to ACK to the host about the
> > > > > commands that have been received. The host will clear the corresponding
> > > > > bits on the host2guest_cmd register. The guest also uses this register
> > > > > to send commands to the host (e.g. when finish free page reporting).
> > > > I am not sure what is the role of guest2host_cmd. Reporting of
> > > > the correct cmd id seems sufficient indication that guest
> > > > received the start command. Not getting any more seems sufficient
> > > > to detect stop.
> > > > 
> > > I think the issue is when the host is waiting for the guest to report pages,
> > > it does not know whether the guest is going to report more or the report is
> > > done already. That's why we need a way to let the guest tell the host "the
> > > report is done, don't wait for more", then the host continues to the next
> > > step - sending the non-free pages to the destination. The following method
> > > is a conclusion of other comments, with some new thought. Please have a
> > > check if it is good.
> > config won't work well for this IMHO.
> > Writes to config register are hard to synchronize with the VQ.
> > For example, guest sends free pages, host says stop, meanwhile
> > guest sends stop for 1st set of pages.
> 
> I still don't see an issue with this. Please see below:
> (before jumping into the discussion, just make sure I've well explained this
> point: now host-to-guest commands are done via config, and guest-to-host
> commands are done via the free page vq)

This is fine by me actually. But right now you have guest to host
not going through vq, going through command register instead -
this is how sending stop to host seems to happen.
If you make it go through vq then I think all will be well.

> 
> Case: Host starts to request the reporting with cmd_id=1. Some time later,
> Host writes "stop" to config, meantime guest happens to finish the reporting
> and plan to actively send a "stop" command from the free_page_vq().
>           Essentially, this is like a sync between two threads - if we view
> the config interrupt handler as one thread, another is the free page
> reporting worker thread.
> 
>         - what the config handler does is simply:
>               1.1:  WRITE_ONCE(vb->reporting_stop, true);
> 
>         - what the reporting thread will do is
>               2.1:  WRITE_ONCE(vb->reporting_stop, true);
>               2.2:  send_stop_to_host_via_vq();
> 
> From the guest point of view, no matter 1.1 is executed first or 2.1 first,
> it doesn't make a difference to the end result - vb->reporting_stop is set.
> 
> From the host point of view, it knows that cmd_id=1 has truly stopped the
> reporting when it receives a "stop" sign via the vq.
> 
> 
> > How about adding a buffer with "stop" in the VQ instead?
> > Wastes a VQ entry which you will need to reserve for this
> > but is it a big deal?
> 
> The free page vq is guest-to-host direction.

Yes, for guest to host stop sign.

> Using it for host-to-guest
> requests will make it bidirectional, which will result in the same issue
> described before: https://lkml.org/lkml/2017/10/11/1009 (the first response)
> 
> On the other hand, I think adding another new vq for host-to-guest
> requesting doesn't make a difference in essence, compared to using config
> (same 1.1, 2.1, 2.2 above), but will be more complicated.

I agree with this. Host to guest can just incremenent the "free command id"
register.

> 
> > > Two new configuration registers in total:
> > > - cmd_reg: the command register, combined from the previous host2guest and
> > > guest2host. I think we can use the same register for host requesting and
> > > guest ACKing, since the guest writing will trap to QEMU, that is, all the
> > > writes to the register are performed in QEMU, and we can keep things work in
> > > a correct way there.
> > > - cmd_id_reg: the sequence id of the free page report command.
> > > 
> > > -- free page report:
> > >      - host requests the guest to start reporting by "cmd_reg |
> > > REPORT_START";
> > >      - guest ACKs to the host about receiving the start reporting request by
> > > "cmd_reg | REPORT_START", host will clear the flag bit once receiving the
> > > ACK.
> > >      - host requests the guest to stop reporting by "cmd_reg | REPORT_STOP";
> > >      - guest ACKs to the host about receiving the stop reporting request by
> > > "cmd_reg | REPORT_STOP", host will clear the flag once receiving the ACK.
> > >      - guest tells the host about the start of the reporting by writing "cmd
> > > id" into an outbuf, which is added to the free page vq.
> > >      - guest tells the host about the end of the reporting by writing "0"
> > > into an outbuf, which is added to the free page vq. (we reserve "id=0" as
> > > the stop sign)
> > > 
> > > -- ballooning:
> > >      - host requests the guest to start ballooning by "cmd_reg | BALLOONING";
> > >      - guest ACKs to the host about receiving the request by "cmd_reg |
> > > BALLOONING", host will clear the flag once receiving the ACK.
> > > 
> > > 
> > > Some more explanations:
> > > -- Why not let the host request the guest to start the free page reporting
> > > simply by writing a new cmd id to the cmd_id_reg?
> > > The configuration interrupt is shared among all the features - ballooning,
> > > free page reporting, and future feature extensions which need host-to-guest
> > > requests. Some features may need to add other feature specific configuration
> > > registers, like free page reporting need the cmd_id_reg, which is not used
> > > by ballooning. The rule here is that the feature specific registers are read
> > > only when that feature is requested via the cmd_reg. For example, the
> > > cmd_id_reg is read only when "cmd_reg | REPORT_START" is true. Otherwise,
> > > when the driver receives a configuration interrupt, it has to read both
> > > cmd_reg and cmd_id registers to know what are requested by the host - think
> > > about the case that ballooning requests are sent frequently while free page
> > > reporting isn't requested, the guest has to read the cmd_id register every
> > > time a ballooning request is sent by the host, which is not necessary. If
> > > future new features follow this style, there will be more unnecessary
> > > VMexits to read the unused feature specific registers.
> > > So I think it is good to have a central control of the feature request via
> > > only one cmd register - reading that one is enough to know what is requested
> > > by the host.
> > > 
> > Right now you are increasing the cost of balloon request 3x though.
> 
> Not that much, I think, just a cmd register read and ACK, and this should be
> neglected compared to the ballooning time.
> (I don't see a difference in the performance testing either).
> 
> Best,
> Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
