Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 5606E6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 12:43:34 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
	<1329399979-3647-10-git-send-email-jack@suse.cz>
	<1329419084.3121.39.camel@doink> <20120220110006.GA6799@quack.suse.cz>
Date: Wed, 29 Feb 2012 09:46:40 -0800
In-Reply-To: <20120220110006.GA6799@quack.suse.cz> (Jan Kara's message of
	"Mon, 20 Feb 2012 12:00:06 +0100")
Message-ID: <m1vcmp8rcv.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH 09/11] sysfs: Push file_update_time() into bin_page_mkwrite()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Alex Elder <elder@dreamhost.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Jan Kara <jack@suse.cz> writes:

> On Thu 16-02-12 13:04:44, Alex Elder wrote:
>> On Thu, 2012-02-16 at 14:46 +0100, Jan Kara wrote:
>> > CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> > Signed-off-by: Jan Kara <jack@suse.cz>
>> > ---
>> >  fs/sysfs/bin.c |    2 ++
>> >  1 files changed, 2 insertions(+), 0 deletions(-)
>> > 
>> > diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
>> > index a475983..6ceb16f 100644
>> > --- a/fs/sysfs/bin.c
>> > +++ b/fs/sysfs/bin.c
>> > @@ -225,6 +225,8 @@ static int bin_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>> >  	if (!sysfs_get_active(attr_sd))
>> >  		return VM_FAULT_SIGBUS;
>> >  
>> > +	file_update_time(file);
>> > +
>> >  	ret = 0;
>> >  	if (bb->vm_ops->page_mkwrite)
>> >  		ret = bb->vm_ops->page_mkwrite(vma, vmf);
>> 
>> If the filesystem's page_mkwrite() function is responsible
>> for updating the time, can't the call to file_update_time()
>> here be conditional?
>> 
>> I.e:
>> 	ret = 0;
>> 	if (bb->vm_ops->page_mkwrite)
>>  		ret = bb->vm_ops->page_mkwrite(vma, vmf);
>> 	else
>> 		file_update_time(file);
>   Hmm, I didn't look previously where do we get bb->vm_ops. It seems they
> are inherited from vma->vm_ops so what you suggest should be safe without
> any further changes. So I can do that if someone who understands the sysfs
> code likes it more.

I do.  Essentially sysfs is being a stackable filesystem here, because
sysfs needs the ability to remove a file mapping.

In practice we could probably get away without a single
file_update_time(file) here because there are mmio mappings.  Normally
for pci resources, but we might as well use good form since we can.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
