Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEEC6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 06:58:44 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y51so38888412wry.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 03:58:44 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id q14si2665797wmd.63.2017.03.03.03.58.43
        for <linux-mm@kvack.org>;
        Fri, 03 Mar 2017 03:58:43 -0800 (PST)
Date: Fri, 3 Mar 2017 11:58:42 +0000
From: Eric Engestrom <eric.engestrom@imgtec.com>
Subject: Re: [RFC PATCH 04/12] staging: android: ion: Call dma_map_sg for
 syncing and mapping
Message-ID: <20170303115841.2fxuhkzo5yazgvrd@imgtec.com>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-5-git-send-email-labbott@redhat.com>
 <20170303110329.GA4132@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
In-Reply-To: <20170303110329.GA4132@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Laura Abbott <labbott@redhat.com>, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Riley Andrews <riandrews@android.com>, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Friday, 2017-03-03 14:04:26 +0300, Dan Carpenter wrote:
> On Thu, Mar 02, 2017 at 01:44:36PM -0800, Laura Abbott wrote:
> >  static struct sg_table *ion_map_dma_buf(struct dma_buf_attachment *attachment,
> >  					enum dma_data_direction direction)
> >  {
> >  	struct dma_buf *dmabuf = attachment->dmabuf;
> >  	struct ion_buffer *buffer = dmabuf->priv;
> > +	struct sg_table *table;
> > +	int ret;
> > +
> > +	/*
> > +	 * TODO: Need to sync wrt CPU or device completely owning?
> > +	 */
> > +
> > +	table = dup_sg_table(buffer->sg_table);
> >  
> > -	ion_buffer_sync_for_device(buffer, attachment->dev, direction);
> > -	return dup_sg_table(buffer->sg_table);
> > +	if (!dma_map_sg(attachment->dev, table->sgl, table->nents,
> > +			direction)){
> > +		ret = -ENOMEM;
> > +		goto err;
> > +	}

Actually, I think `ret` should be left uninitialised on success,
what's really missing is this return before the `err:` label:

+	return table;


> > +
> > +err:
> > +	free_duped_table(table);
> > +	return ERR_PTR(ret);
> 
> ret isn't initialized on success.
> 
> >  }
> >  
> 
> regards,
> dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
