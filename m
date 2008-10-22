Date: Wed, 22 Oct 2008 14:28:57 -0700 (PDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0810221416130.26639@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>  <48FE6306.6020806@linux-foundation.org>
  <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810220822500.30851@quilx.com>
  <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221252570.3562@quilx.com>
  <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221315080.26671@quilx.com>
  <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu> <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Miklos Szeredi wrote:

>> Actually, when debugging is enabled, it's customary to poison the
>> object, for example (see free_debug_processing() in mm/slub.c). So we
>> really can't "easily ensure" that in the allocator unless we by-pass
>> all the current debugging code.

Plus the allocator may be reusing parts of the freed object for a freelist 
etc even if the object is not poisoned.

> Thank you, that does actually answer my question.  I would still think
> it's a good sacrifice to no let the dentries be poisoned for the sake
> of a simpler dentry defragmenter.

You can simplify defrag by not doing anything in the get() method. That 
means some of the objects passed to the kick() method may be already have 
been freed in the interim.

The kick method then must be able to determine if the object has already 
been freed (or is undergoing freeing) by inspecting the object contents 
(allocations are held off until kick() is complete). It then needs to free 
only the objects that are still allocated.

That way you could get to a one stage system.... If the dentry code can 
give us that then the approach would become much simpler.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
