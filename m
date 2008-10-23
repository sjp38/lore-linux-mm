Date: Thu, 23 Oct 2008 07:25:21 -0700 (PDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <84144f020810230714g7f5d36bas812ad691140ee453@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0810230721400.12497@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221416130.26639@quilx.com>
  <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>  <1224745831.25814.21.camel@penberg-laptop>
  <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810230638450.11924@quilx.com>
  <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>
 <Pine.LNX.4.64.0810230705210.12497@quilx.com>
 <84144f020810230714g7f5d36bas812ad691140ee453@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Miklos Szeredi <miklos@szeredi.hu>, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008, Pekka Enberg wrote:

>> The problem looks like its freeing objects on a different processor that
>> where it was used last. With the pointer array it is only necessary to touch
>> the objects that contain the arrays.
>
> Interesting. SLAB gets away with this because of per-cpu caches or
> because it uses the bufctls instead of a freelist?

Exactly. Slab adds a special management structure to each slab page that 
contains the freelist and other stuff. Freeing first occurs to a per cpu 
queue that contains an array of pointers. Then later the objects are moved 
from the pointer array into the management structure for the slab.

What we could do for SLUB is to generate a linked list of pointer arrays 
in the free objects of a slab page. If all objects are allocated then no 
pointer array is needed. The first object freed would become the first 
pointer array. If that is found to be exhausted then the object currently 
being freed is becoming the next pointer array and we put a link to the 
old one into the object as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
