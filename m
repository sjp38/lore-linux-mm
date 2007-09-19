Message-ID: <46F06C17.5050203@google.com>
Date: Tue, 18 Sep 2007 17:23:51 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] cpuset dirty limits
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com> <46E743F8.9050206@google.com> <20070914161540.5b192348.akpm@linux-foundation.org> <Pine.LNX.4.64.0709171153010.27542@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0709171153010.27542@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, pj@sgi.com, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 14 Sep 2007, Andrew Morton wrote:
> 
>>> +	mutex_lock(&callback_mutex);
>>> +	*cs_int = val;
>>> +	mutex_unlock(&callback_mutex);
>> I don't think this locking does anything?
> 
> Locking is wrong here. The lock needs to be taken before the cs pointer 
> is dereferenced from the caller.

	I think we can just remove the callback_mutex lock. Since the change is
coming from an update to a cpuset filesystem file, the cpuset is not
going anywhere since the inode is open. And I don't see that any code
really cares whether the dirty ratios change out from under them.

> 
>>> +	return 0;
>>> +}
>>> +
>>>  /*
>>>   * Frequency meter - How fast is some event occurring?
>>>   *
>>> ...
>>> +void cpuset_get_current_ratios(int *background_ratio, int *throttle_ratio)
>>> +{
>>> +	int background = -1;
>>> +	int throttle = -1;
>>> +	struct task_struct *tsk = current;
>>> +
>>> +	task_lock(tsk);
>>> +	background = task_cs(tsk)->background_dirty_ratio;
>>> +	throttle = task_cs(tsk)->throttle_dirty_ratio;
>>> +	task_unlock(tsk);
>> ditto?
> 
> It is required to take the task lock while dereferencing the tasks cpuset 
> pointer.

	Agreed.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
