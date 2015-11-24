Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 814516B0253
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:23:27 -0500 (EST)
Received: by qgeb1 with SMTP id b1so21965480qge.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 15:23:27 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0076.outbound.protection.outlook.com. [65.55.169.76])
        by mx.google.com with ESMTPS id u102si18252985qge.90.2015.11.24.15.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 15:23:26 -0800 (PST)
Subject: Re: [PATCH] Fix a bdi reregistration race, v2
References: <564F9AFF.3050605@sandisk.com>
 <20151124231331.GA25591@infradead.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <5654F169.6070000@sandisk.com>
Date: Tue, 24 Nov 2015 15:23:21 -0800
MIME-Version: 1.0
In-Reply-To: <20151124231331.GA25591@infradead.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: James Bottomley <jbottomley@parallels.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, Aaro Koskinen <aaro.koskinen@iki.fi>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-mm@kvack.org

On 11/24/2015 03:13 PM, Christoph Hellwig wrote:
> What sort of re-registration is this? Seems like we should only
> release the minor number once the bdi is released.

Hello Christoph,

As you most likely know the BDI device name for disks is based on the 
device major and minor number:

$ ls -l /dev/sda
brw-rw---- 1 root disk 8, 0 Nov 24 14:53 /dev/sda
$ ls -l /sys/block/sda/bdi
lrwxrwxrwx 1 root root 0 Nov 24 15:17 /sys/block/sda/bdi -> 
../../../../../../../../virtual/bdi/8:0

So if a driver stops using a (major, minor) number pair and the same 
device number is reused before the bdi device has been released the 
warning mentioned in the patch description at the start of this thread 
is triggered. This patch fixes that race by removing the bdi device from 
sysfs during the __scsi_remove_device() call instead of when the bdi 
device is released.

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
