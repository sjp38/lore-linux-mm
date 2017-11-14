Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 144336B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:21:18 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id z82so4294709oia.4
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:21:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m60si8197168otc.442.2017.11.14.13.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 13:21:16 -0800 (PST)
Date: Tue, 14 Nov 2017 23:21:03 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v17 6/6] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20171114230805-mutt-send-email-mst@kernel.org>
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
 <1509696786-1597-7-git-send-email-wei.w.wang@intel.com>
 <5A097548.8000608@intel.com>
 <20171113192309-mutt-send-email-mst@kernel.org>
 <5A0ADB3B.4070407@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A0ADB3B.4070407@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, Nitesh Narayan Lal <nilal@redhat.com>, Rik van Riel <riel@redhat.com>

On Tue, Nov 14, 2017 at 08:02:03PM +0800, Wei Wang wrote:
> On 11/14/2017 01:32 AM, Michael S. Tsirkin wrote:
> > > - guest2host_cmd: written by the guest to ACK to the host about the
> > > commands that have been received. The host will clear the corresponding
> > > bits on the host2guest_cmd register. The guest also uses this register
> > > to send commands to the host (e.g. when finish free page reporting).
> > I am not sure what is the role of guest2host_cmd. Reporting of
> > the correct cmd id seems sufficient indication that guest
> > received the start command. Not getting any more seems sufficient
> > to detect stop.
> > 
> 
> I think the issue is when the host is waiting for the guest to report pages,
> it does not know whether the guest is going to report more or the report is
> done already. That's why we need a way to let the guest tell the host "the
> report is done, don't wait for more", then the host continues to the next
> step - sending the non-free pages to the destination. The following method
> is a conclusion of other comments, with some new thought. Please have a
> check if it is good.

config won't work well for this IMHO.
Writes to config register are hard to synchronize with the VQ.
For example, guest sends free pages, host says stop, meanwhile
guest sends stop for 1st set of pages.

How about adding a buffer with "stop" in the VQ instead?
Wastes a VQ entry which you will need to reserve for this
but is it a big deal?


> Two new configuration registers in total:
> - cmd_reg: the command register, combined from the previous host2guest and
> guest2host. I think we can use the same register for host requesting and
> guest ACKing, since the guest writing will trap to QEMU, that is, all the
> writes to the register are performed in QEMU, and we can keep things work in
> a correct way there.
> - cmd_id_reg: the sequence id of the free page report command.
> 
> -- free page report:
>     - host requests the guest to start reporting by "cmd_reg |
> REPORT_START";
>     - guest ACKs to the host about receiving the start reporting request by
> "cmd_reg | REPORT_START", host will clear the flag bit once receiving the
> ACK.
>     - host requests the guest to stop reporting by "cmd_reg | REPORT_STOP";
>     - guest ACKs to the host about receiving the stop reporting request by
> "cmd_reg | REPORT_STOP", host will clear the flag once receiving the ACK.
>     - guest tells the host about the start of the reporting by writing "cmd
> id" into an outbuf, which is added to the free page vq.
>     - guest tells the host about the end of the reporting by writing "0"
> into an outbuf, which is added to the free page vq. (we reserve "id=0" as
> the stop sign)
> 
> -- ballooning:
>     - host requests the guest to start ballooning by "cmd_reg | BALLOONING";
>     - guest ACKs to the host about receiving the request by "cmd_reg |
> BALLOONING", host will clear the flag once receiving the ACK.
> 
> 
> Some more explanations:
> -- Why not let the host request the guest to start the free page reporting
> simply by writing a new cmd id to the cmd_id_reg?
> The configuration interrupt is shared among all the features - ballooning,
> free page reporting, and future feature extensions which need host-to-guest
> requests. Some features may need to add other feature specific configuration
> registers, like free page reporting need the cmd_id_reg, which is not used
> by ballooning. The rule here is that the feature specific registers are read
> only when that feature is requested via the cmd_reg. For example, the
> cmd_id_reg is read only when "cmd_reg | REPORT_START" is true. Otherwise,
> when the driver receives a configuration interrupt, it has to read both
> cmd_reg and cmd_id registers to know what are requested by the host - think
> about the case that ballooning requests are sent frequently while free page
> reporting isn't requested, the guest has to read the cmd_id register every
> time a ballooning request is sent by the host, which is not necessary. If
> future new features follow this style, there will be more unnecessary
> VMexits to read the unused feature specific registers.
> So I think it is good to have a central control of the feature request via
> only one cmd register - reading that one is enough to know what is requested
> by the host.
> 

Right now you are increasing the cost of balloon request 3x though.


How about we establish a baseline with a simple interface, and
then add the command register when it's actually benefitial.



> Best,
> Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
