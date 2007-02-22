Message-ID: <45DE108C.6010101@redhat.com>
Date: Thu, 22 Feb 2007 16:52:12 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu>	 <20070221202615.a0a167f4.akpm@linux-foundation.org>	 <E1HK8hU-0005Mq-00@dorka.pomaz.szeredi.hu> <45DDD55F.4060106@redhat.com>	 <E1HKIN1-0006RX-00@dorka.pomaz.szeredi.hu> <45DDF9C1.4090003@redhat.com>	 <E1HKKrL-0006k6-00@dorka.pomaz.szeredi.hu> <1172178253.6382.12.camel@heimdal.trondhjem.org> <E1HKLUp-0006qY-00@dorka.pomaz.szeredi.hu>
In-Reply-To: <E1HKLUp-0006qY-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: trond.myklebust@fys.uio.no, akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
>>>> This still does not address the situation where a file is 'permanently'
>>>> mmap'd, does it?
>>>>         
>>> So?  If application doesn't do msync, then the file times won't be
>>> updated.  That's allowed by the standard, and so portable applications
>>> will have to call msync.
>>>       
>> It is allowed, but it is clearly not useful behaviour. Nowhere is it set
>> in stone that we should be implementing just the minimum allowed.
>>     
>
> You're right.  In theory, at least.  But in practice I don't think
> this matters.  Show me an application that writes to a shared mapping
> then doesn't call either msync or munmap and doesn't even exit.
>
> If there were lot of these apps, then this bug would have been fixed
> lots of years earlier.  In fact there are _very_ few apps writing to
> shared mappings at all.
>
>   

Perhaps true, although I know of at least one customer of Red Hat who
does have an application (or more) than uses mmap'd files and is
suffering from this lack of appropriate semantics.  They are not
getting files backed up which need to be.

> Applications should be encouraged to call msync(MS_ASYNC) because:
>
>   - it's very fast (basically a no-op) on recent linux kernels
>
>   - it's the only portable way to guarantee, that the data you written
>     will _ever_ hit the disk.
>
> There's really no downside to using msync(MS_ASYNC) in your
> application, so making an effort to support applications that don't do
> this is stupid, IMO.

It may be a no-op on recent Linux kernels, but I don't think that it
is a no-op on other systems.

I do not wish to defend applications which don't use msync or some
such, but it seems that the appropriate semantics to support are
more than just depending upon the application to "do the right thing".

    Thanx...

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
