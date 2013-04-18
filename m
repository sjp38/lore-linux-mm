Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 2F6E06B003B
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 19:41:25 -0400 (EDT)
Message-ID: <1366327735.3824.50.camel@misato.fc.hp.com>
Subject: Re: [Bug fix PATCH v4] Reusing a resource structure allocated by
 bootmem
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 18 Apr 2013 17:28:55 -0600
In-Reply-To: <517082B9.7050708@jp.fujitsu.com>
References: <516FB07C.9010603@jp.fujitsu.com>
	 <1366295000.3824.47.camel@misato.fc.hp.com>
	 <517082B9.7050708@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linuxram@us.ibm.com, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2013-04-19 at 08:33 +0900, Yasuaki Ishimatsu wrote:
 :
> >
> >> +static struct resource *get_resource(gfp_t flags)
> >> +{
> >> +	struct resource *res = NULL;
> >> +
> >> +	spin_lock(&bootmem_resource_lock);
> >> +	if (bootmem_resource.sibling) {
> >> +		res = bootmem_resource.sibling;
> >> +		bootmem_resource.sibling = res->sibling;
> >> +		memset(res, 0, sizeof(struct resource));
> >> +	}
> >> +	spin_unlock(&bootmem_resource_lock);
> >
> 
> > I prefer to keep memset() outside of the spin lock.
> >
> > spin_lock(&bootmem_resource_lock);
> > if (..) {
> > 	:
> > 	spin_unlock(&bootmem_resource_lock);
> > 	memset(res, 0, sizeof(struct resource));
> > } else {
> > 	spin_unlock(&bootmem_resource_lock);
> > 	res = kzalloc(sizeof(struct resource), flags);
> > }
> 
> Hmm. It is a little ugly. How about it?
> 
> spin_lock(&bootmem_resource_lock);
> if (bootmem_resource.sibling) {
> 	res = bootmem_resource.sibling;
> 	bootmem_resource.sibling = res->sibling;
> }
> spin_unlock(&bootmem_resource_lock);
> 
> if (res)
> 	memset(res, 0, sizeof(struct resource));
> else	
> 	res = kzalloc(sizeof(struct resource), flags);

Sounds good to me.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
